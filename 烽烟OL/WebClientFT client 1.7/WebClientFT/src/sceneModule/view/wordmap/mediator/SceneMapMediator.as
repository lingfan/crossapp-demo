package sceneModule.view.wordmap.mediator
{
	import com.greensock.TweenLite;
	
	import event.ApplicationReplaceModuleEvent;
	import event.GuidEvent;
	import event.GuidEventCenter;
	import event.KeyFuncEvent;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import managers.KeyBordManager;
	import managers.WindowManager;
	
	import model.GuideInfo;
	import model.SystemDataModel;
	
	import mx.controls.Button;
	import mx.core.UIComponent;
	
	import org.robotlegs.mvcs.Mediator;
	
	import proto.map.InstanceMapInfo;
	import proto.map.SceneMapInfo;
	
	import resource.AssetCenter;
	import resource.AssetItemInfo;
	import resource.CrotaResourceConfig;
	
	import sceneModule.view.copyScene.view.BitmapButton;
	import sceneModule.view.task.command.TaskMessage;
	import sceneModule.view.wordmap.model.MapConfig;
	import sceneModule.view.wordmap.model.MapMessage;
	import sceneModule.view.wordmap.model.MapPacePosInfo;
	import sceneModule.view.wordmap.view.ChangeColorSp;
	import sceneModule.view.wordmap.view.InstancePlaceTip;
	import sceneModule.view.wordmap.view.SceneMapView;
	import sceneModule.view.wordmap.view.ScenePlaceTip;
	
	import service.ISocketServer;
	
	import util.CommonTools;
	import util.DelayExcuter;
	import util.HashMap;
	import util.xtrace;
	
	
	//场景地图视图管理器
	public class SceneMapMediator extends Mediator
	{
		public static const CHAR_H:int = 110;
		public static const CHAR_W:int = 64;
		
		public static const LEVEL_LIMIT:Object = {
			1000:0,
			1100:0,
			1200:0,
			1300:0,
			1400:0,
			1500:0,
			1600:0,
			1700:0,
			1800:0
		}
		
		private var _word_btn_x:int = 837;
		private var _word_btn_y:int = 535;
		
		private var _exit_btn_x:int = 828;
		
		private var _change_color_sp_x:int = 495;
		private var _change_color_sp_y:int = 395;
		
		private var _union_color_x:int = 858;
		private var _union_color_y:int = 515;
		private var _change_btn_x:int = 908;
		private var _change_btn_y:int = 507;
		
		
		private var _block_w:int = 46;
		private var _block_h:int = 14;
		
		private var _window_bg:Bitmap;
		private var _bg:Bitmap;
		private var _show_place_contain:Sprite;
		private var _highlight_b:Bitmap;
		private var _mouse_place_contain:Sprite;
		private var _topBitmap:Bitmap;
		private var _player_contain:Sprite;
		private var _tips_contain:Sprite;
		
		private var _scene_place_tip:ScenePlaceTip;
		private var _instance_place_tip:InstancePlaceTip;
		
		private var _to_word_btn:BitmapButton;
		private var _exit_btn:BitmapButton;
		private var _change_color_btn:BitmapButton;
		
		private var _change_color_sp:ChangeColorSp;
		private var _union_color:Sprite;
		
		private var _player_mc:MovieClip;
		
		private var _infos:HashMap;
		private var _curmap:int;
		private var _cur_mouse_b:Bitmap;
		
		private var _scene_id:int;
		[Inject]
		public var smv:SceneMapView;
		[Inject]
		public var socket:ISocketServer;
		
		public function SceneMapMediator()
		{
			super();
		}
		
		override public function onRegister():void {
			//test
			_scene_id =  0;
			//end test
			
//			smv.bt1.addEventListener(MouseEvent.CLICK,clickbt1);
//			smv.bt2.addEventListener(MouseEvent.CLICK,clickbt2);
//			smv.bt3.addEventListener(MouseEvent.CLICK,clickbt3);
//			smv.bt4.addEventListener(MouseEvent.CLICK,clickbt4);
//			smv.bt5.addEventListener(MouseEvent.CLICK,clickbt5);
			_infos = new HashMap();
			_curmap = -1;
			
			MapMessage.getInstance().addEventListener(MapMessage.MapMessage_EVENT_REFRESH_PLACE_COLOR, refresh_place_color);
			MapMessage.getInstance().addEventListener(MapMessage.MapMessage_EVENT_REFRESH_SELF_COLOR, refresh_self_color);
			MapMessage.getInstance().addEventListener(MapMessage.MapMessage_EVENT_CLOSE_COLOR_SP, close_color);
			
			_window_bg = new Bitmap();
			bg_contain.addChild(_window_bg);
			
			_bg = new Bitmap();
			contain.addChild(_bg);
			
			_show_place_contain = new Sprite();
			_show_place_contain.mouseEnabled = false;
			_show_place_contain.mouseChildren = false;
			_show_place_contain.alpha = 0.5;
			contain.addChild(_show_place_contain);
			
			_highlight_b = new Bitmap();
			contain.addChild(_highlight_b);
			
			_mouse_place_contain = new Sprite();
			_mouse_place_contain.alpha = 0;
			_mouse_place_contain.addEventListener(Event.ENTER_FRAME, enter_frame);
			//_mouse_place_contain.addEventListener(MouseEvent.CLICK, to_target_scene);
			contain.addChild(_mouse_place_contain);
			
			
			_to_word_btn = new BitmapButton('map_scene_base', 'to_word_btn_up', 'to_word_btn_over', 'to_word_btn_down', 'to_word_btn_disable');
			_to_word_btn.x = _word_btn_x;
			_to_word_btn.y = _word_btn_y;
			_to_word_btn.addEventListener(MouseEvent.CLICK, to_word_map);
			//contain.addChild(_to_word_btn);
			
			_exit_btn = new BitmapButton('map_scene_base', 'exit_btn_up', 'exit_btn_over', 'exit_btn_down', 'exit_btn_disable');
			_exit_btn.x = _exit_btn_x;
			_exit_btn.y = _word_btn_y;
			_exit_btn.addEventListener(MouseEvent.CLICK, on_exit);
			contain.addChild(_exit_btn);
			
			
			_change_color_btn = new BitmapButton('map_scene_base', 'change_color_up', 'change_color_over', 'change_color_over', 'change_color_disable');
			_change_color_btn.x = _change_btn_x;
			_change_color_btn.y = _change_btn_y;
			_change_color_btn.addEventListener(MouseEvent.CLICK, change_color);
			contain.addChild(_change_color_btn);
			
			_union_color = new Sprite();
			_union_color.x = _union_color_x;
			_union_color.y = _union_color_y;
			contain.addChild(_union_color);
			
			_change_color_sp = new ChangeColorSp();
			_change_color_sp.x = _change_color_sp_x;
			_change_color_sp.y = _change_color_sp_y;
			
			_player_contain = new Sprite();
			contain.addChild(_player_contain);
			
			_topBitmap = new Bitmap();
			contain.addChild(_topBitmap);
			
			_tips_contain = new Sprite();
			contain.addChild(_tips_contain);
			
			_scene_place_tip = new ScenePlaceTip();
			_instance_place_tip = new InstancePlaceTip();
			
			var taget_city:int = TaskMessage.getInstance().find_path_check_wordmap();
			if (0 != taget_city) {
				word_map_loaded();
			}
			else {
				show();
				//申请区域地图数据
				MapMessage.getInstance().requese_instance_map_info();
			}
			
			contain.addEventListener(Event.REMOVED_FROM_STAGE , remove_from_stage);
			
			MapMessage.getInstance().requese_scene_map_info();
		}
		
		private function remove_from_stage(e:Event):void {
			preRemove();
		}
		//test
		private function clickbt1(e:MouseEvent):void {
			MapMessage.getInstance().requese_change_map(1400);
		}
		private function clickbt2(e:MouseEvent):void {
			MapMessage.getInstance().requese_change_map(1500);
		}
		private function clickbt3(e:MouseEvent):void {
			MapMessage.getInstance().requese_change_map(1600);
		}
		private function clickbt4(e:MouseEvent):void {
			MapMessage.getInstance().requese_change_map(1700);
		}
		private function clickbt5(e:MouseEvent):void {
			MapMessage.getInstance().requese_change_map(1800);
		}
		
		
		
		
		//end test
		override public function preRemove():void {
			contain.removeEventListener(Event.REMOVED_FROM_STAGE , remove_from_stage);
			_mouse_place_contain.removeEventListener(Event.ENTER_FRAME, enter_frame);
			_mouse_place_contain.removeEventListener(MouseEvent.CLICK, to_target_scene);
			
			_to_word_btn.removeEventListener(MouseEvent.CLICK, to_word_map);
			_exit_btn.removeEventListener(MouseEvent.CLICK, on_exit);
			_change_color_btn.removeEventListener(MouseEvent.CLICK, change_color);
			
			MapMessage.getInstance().removeEventListener(MapMessage.MapMessage_EVENT_REFRESH_PLACE_COLOR, refresh_place_color);
			MapMessage.getInstance().removeEventListener(MapMessage.MapMessage_EVENT_REFRESH_SELF_COLOR, refresh_self_color);
			MapMessage.getInstance().removeEventListener(MapMessage.MapMessage_EVENT_CLOSE_COLOR_SP, close_color);
			
			close_color();
			
			if (_window_bg && _window_bg.bitmapData) {
				_window_bg.bitmapData = null;
			}
			_window_bg = null;
			
			if (_bg) {
				_bg.bitmapData = null;
			}
			_bg = null;
			
			if (_highlight_b && _highlight_b.bitmapData) {
				_highlight_b.bitmapData.dispose();
				_highlight_b.bitmapData = null;
			}
			_highlight_b = null;
			
			for each (var item:Bitmap in _infos.values()) 
			{
				if (item.bitmapData) {
					item.bitmapData.dispose();
					item.bitmapData = null;
				}
			}
			_infos.clear();
			
			
			while (_show_place_contain.numChildren > 0) {
				var tb:Bitmap = _show_place_contain.removeChildAt(0) as Bitmap;
				if (tb) {
					if (tb.bitmapData) {
						tb.bitmapData.dispose();
						tb.bitmapData = null;
					}
				}
			}
			
			clear_tip();
		}
		
		private function close_color(e:Event = null):void {
			if (_change_color_sp.stage) {
				remove_child(_change_color_sp);
			}
			if (0 == _scene_id) {
				MapMessage.getInstance().requese_scene_map_info();
			}
			else {
				MapMessage.getInstance().requese_instance_map_info();
			}
		}
		
		private function change_color(e:Event):void {
			if (_change_color_sp.stage) {
				remove_child(_change_color_sp);
			}
			else {
				if (!_change_color_btn.is_disable) {
					contain.addChild(_change_color_sp);
				}
			}
		}
		
		private function enter_frame(e:Event):void {
			var pt:Point = new Point(contain.stage.mouseX, contain.stage.mouseY);
			var arr:Array = contain.stage.getObjectsUnderPoint(pt);
			var len:int = arr.length;
			var is_have:Boolean = false;
			for (var i:int = len - 1; i >= 0 ; i--) 
			{
				var b:Bitmap = arr[i] as Bitmap;
				if (null != b) {
					if (_mouse_place_contain.contains(b)) {
						var pix:uint = b.bitmapData.getPixel(b.mouseX, b.mouseY);
						if (pix > 0) {
							if (_cur_mouse_b != b) {
								clear_tip();
							}
							_cur_mouse_b = b;
							highlight(pix);
							is_have = true;
							break;
						}
					}
				}
			}
			if (!is_have) {
				_cur_mouse_b = null;
				highlight(-1);
			}
		}
		
		private function to_word_map(e:MouseEvent = null):void {
			xtrace("to word map");
			var t_arr:Array = [];
			
			var std_swf:AssetItemInfo = new AssetItemInfo();
			std_swf.package_id = 'map_scene_0';
			std_swf.id = 'word_map_std';
			std_swf.type = AssetItemInfo.AssetItemInfo_TYPE_SWF;
			std_swf.path = CommonTools.getJobImg(SystemDataModel.roleInfo.profession) + "_stand.swf";
			
			var move_swf:AssetItemInfo = new AssetItemInfo();
			move_swf.package_id = 'map_scene_0';
			move_swf.id = 'word_map_move';
			move_swf.type = AssetItemInfo.AssetItemInfo_TYPE_SWF;
			move_swf.path = CommonTools.getJobImg(SystemDataModel.roleInfo.profession) + ".swf";
			
			var movel_swf:AssetItemInfo = new AssetItemInfo();
			movel_swf.package_id = 'map_scene_0';
			movel_swf.id = 'word_map_move_l';
			movel_swf.type = AssetItemInfo.AssetItemInfo_TYPE_SWF;
			movel_swf.path = CommonTools.getJobImg(SystemDataModel.roleInfo.profession) + "_walk_L.swf";
			
			t_arr.push(std_swf);
			t_arr.push(move_swf);
			t_arr.push(movel_swf);
			
			AssetCenter.getInstance().load_package('map_scene_0', word_map_loaded, null, true, null, null, t_arr, ['map_scene_base']);
		}
		
		private function on_exit(e:MouseEvent):void {
			KeyBordManager.getInstance().dispatchEvent(new KeyFuncEvent(KeyFuncEvent.KeyFuncEvent_MAP_CHANGE));
		}
		
		private function to_target_scene(e:MouseEvent):void {
			if (0 == _scene_id) {
				var pt:Point = new Point(contain.stage.mouseX, contain.stage.mouseY);
				var arr:Array = contain.stage.getObjectsUnderPoint(pt);
				var len:int = arr.length;
				var is_have:Boolean = false;
				for (var i:int = len - 1; i >= 0 ; i--) 
				{
					var b:Bitmap = arr[i] as Bitmap;
					if (null != b) {
						if (_mouse_place_contain.contains(b)) {
							var pix:uint = b.bitmapData.getPixel(b.mouseX, b.mouseY);
							if (pix > 0) {
								xtrace("hit " + pix);
								
								var place_id:int = find_placeid_by_bitmap(b);
								
								if (!is_level_ok(place_id)) {
									xtrace("等级不允许移动");
									//WindowManager.createWindow(NCorpAlert.NAME,{msg:msg,tips:tips},null,false,false,false,null,mediatorMap,popUpWindowLayer,true);
									return;
								}
								
								var pos_x:int = b.x + b.width / 2 - CHAR_W;
								var pos_y:int = b.y + b.height / 2 - CHAR_H;
								var old_x:int = _player_mc.x;
								var old_y:int = _player_mc.y;
								
								if (pos_x == old_x) {
									return;
								}
								
								TweenLite.killTweensOf(_player_mc);
								remove_child(_player_mc);
								
								if (pos_x > old_x) {
									//向右移动
									_player_mc = AssetCenter.getInstance().get_mc_form_pacakge('map_scene_0', 'word_map_move');
								}
								else {
									//向左移动
									_player_mc = AssetCenter.getInstance().get_mc_form_pacakge('map_scene_0', 'word_map_move_l');
								}
								_player_mc.x = old_x;
								_player_mc.y = old_y;
								_player_mc.mouseEnabled = false;
								_player_mc.mouseChildren = false;
								_player_contain.addChild(_player_mc);
								
								
								TweenLite.to(
									_player_mc, 2, 
									{ 
										x:pos_x, y:pos_y ,
										onComplete:move_over,
										onCompleteParams:[place_id]
									}
								);
								MapConfig.getInstance().move_ing = true;
								break;
							}
						}
						
					}
				}
			}
		}
		
		private function is_level_ok(id:int):Boolean {
			var r:Boolean = false;
			var p_l:int = SystemDataModel.roleInfo.level;
			var t_l:int = LEVEL_LIMIT[id];
			if (p_l < t_l) {
				r = false;
			}
			else {
				r = true;
			}
			return r;
		}
		
		private function refresh_place_color(e:Event):void {
			clear_sp(_show_place_contain);
			if (0 == _scene_id) {
				//世界地图
				draw_scene_place();
			}
			else {
				draw_instance_place();
			}
		}
		//显示四个大地图
		private function draw_scene_place():void {
			var arr:Array = MapMessage.getInstance().scene_infos;
			for each (var item:SceneMapInfo in arr) 
			{
				var b:Bitmap = _infos.get(item.id) as Bitmap;
				if (null == b) {
					xtrace("no place info " + item.id);
					continue;
				}
				if (0 == item.color) {
					xtrace("no color info " + item.id);
					continue;
				}
				var bd:BitmapData = b.bitmapData;
				var place_colir:uint = 0xFF000000 + item.color;
				var placebd:BitmapData = new BitmapData(bd.width, bd.height, true, 0);
				placebd.threshold(bd, new Rectangle(0, 0, bd.width, bd.height), new Point(0, 0), ">", 0, place_colir);
				var placeb:Bitmap = new Bitmap(placebd);
				placeb.x = b.x;
				placeb.y = b.y;
				_show_place_contain.addChild(placeb);
			}
		}
		//显示1100,1200,……里面的小地图
		private function draw_instance_place():void {
			var arr:Array = MapMessage.getInstance().instance_infos;
			for each (var item:InstanceMapInfo in arr) 
			{
				var b:Bitmap = _infos.get(item.id) as Bitmap;
				if (null == b) {
					xtrace("no place info " + item.id);
					continue;
				}
				if (0 == item.color) {
					xtrace("no color info " + item.id);
					continue;
				}
				var bd:BitmapData = b.bitmapData;
				var place_colir:uint = 0x80000000 + item.color;
				var placebd:BitmapData = new BitmapData(bd.width, bd.height, true, 0);
				placebd.threshold(bd, new Rectangle(0, 0, bd.width, bd.height), new Point(0, 0), ">", 0, place_colir);
				var placeb:Bitmap = new Bitmap(placebd);
				placeb.x = b.x;
				placeb.y = b.y;
				_show_place_contain.addChild(placeb);
			}
		}
		
		private function refresh_self_color(e:Event):void {
			_union_color.graphics.clear();
			_union_color.graphics.beginFill(MapMessage.getInstance().self_color);
			_union_color.graphics.drawRoundRect(0, 0, _block_w, _block_h, 1, 1);
			_union_color.graphics.endFill();
		}
		
		private function to_place(place_id:int):void {
			TweenLite.killTweensOf(_player_mc);
			remove_child(_player_mc);
			
			var b:Bitmap = _infos.get(place_id);
			var pos_x:int = b.x + b.width / 2 - CHAR_W;
			var pos_y:int = b.y + b.height / 2 - CHAR_H;
			
			var old_x:int = _player_mc.x;
			var old_y:int = _player_mc.y;
			
			if (pos_x > old_x) {
				//向右移动
				_player_mc = AssetCenter.getInstance().get_mc_form_pacakge('map_scene_0', 'word_map_move');
			}
			else {
				//向左移动
				_player_mc = AssetCenter.getInstance().get_mc_form_pacakge('map_scene_0', 'word_map_move_l');
			}
			_player_mc.x = old_x;
			_player_mc.y = old_y;
			_player_mc.mouseEnabled = false;
			_player_mc.mouseChildren = false;
			_player_contain.addChild(_player_mc);
			
			
			TweenLite.to(
				_player_mc, 2, 
				{ 
					x:pos_x, y:pos_y ,
					onComplete:move_over,
					onCompleteParams:[place_id]
				}
			);
			MapConfig.getInstance().move_ing = true;
		}
		
		private function find_placeid_by_bitmap(b:Bitmap):int {
			var r:int = -1;
			var keys:Array = _infos.keys();
			for each (var item:int in keys) 
			{
				var c_b:Bitmap = _infos.getValue(item);
				if (c_b == b) {
					r = item;
					break;
				}
			}
			return r;
		}
		
		private function move_over(place_id:int):void {
			MapConfig.getInstance().move_ing = false;
			
			if (place_id == SystemDataModel.placeId) {
				KeyBordManager.getInstance().dispatchEvent(new KeyFuncEvent(KeyFuncEvent.KeyFuncEvent_MAP_CHANGE));
				return;
			}
			var old_x:int = _player_mc.x;
			var old_y:int = _player_mc.y;
			remove_child(_player_mc);
			_player_mc = AssetCenter.getInstance().get_mc_form_pacakge('map_scene_0', 'word_map_std');
			_player_mc.x = old_x;
			_player_mc.y = old_y;
			_player_contain.addChild(_player_mc);
			
			MapMessage.getInstance().requese_change_map(place_id);
		}
		
		private function remove_child(dis:DisplayObject):void {
			var par:DisplayObjectContainer = dis.parent;
			if (null != par) {
				par.removeChild(dis);
			}
		}
		
		private function word_map_loaded():void {
			if (!_window_bg) {
				return;
			}
			_scene_id = 0;
			show();
			MapMessage.getInstance().requese_scene_map_info();
			var taget_city:int = TaskMessage.getInstance().find_path_check_wordmap();
			if (0 != taget_city) {
				new DelayExcuter(1000, to_place, [taget_city]);
			}
			GuidEventCenter.getInstance().dispatchEvent(new GuidEvent(GuideInfo.TYPE_OPEN_UI, GuideInfo.UI_MAP_SCENE));
		}
		
		private function highlight(index:int):void {
			if (index == _curmap) {
				if (-1 != _curmap) {
					move_tip();
				}
				return;
			}
			if (null != _highlight_b.bitmapData) {
				_highlight_b.bitmapData.dispose();
			}
			if (-1 == index) {
				if (null != _highlight_b.bitmapData) {
					_highlight_b.bitmapData.dispose();
					clear_tip();
				}
				_curmap = index;
				return;
			}
			var source_bd:BitmapData = AssetCenter.getInstance().get_img_form_pacakge('map_scene_' + _scene_id, index + "");
			var pos:Array = MapPacePosInfo.POS_INFO[_scene_id][index];
			var bd:BitmapData = new BitmapData(source_bd.width, source_bd.height, true, 0);
			var tcolor:uint = 0x80000000 + 0xFFFF00;
			bd.threshold(source_bd, new Rectangle(0, 0, source_bd.width, source_bd.height), new Point(0, 0), ">", 0, tcolor);
			_highlight_b.bitmapData = bd;
			_highlight_b.x = pos[0];
			_highlight_b.y = pos[1];
			_curmap = index;
			
			show_tips();
		}
		
		private function show_tips():void {
			if (-1 == _curmap) {
				clear_tip();
				return;
			}
			if (0 == _scene_id) {
				show_scene_tip();
			}
			else {
				show_instance_tip();
			}
		}
		
		private function clear_tip():void {
			clear_sp(_tips_contain);
		}
		
		private function get_scene_info_by_id(id:int):SceneMapInfo {
			var arr:Array = MapMessage.getInstance().scene_infos;
			//return null;
			for each (var item:SceneMapInfo in arr) 
			{
				if (item.id == id) {
					if (item.color == 0) {
					//没有被占领
						return null;
					}
					else {
						return item;
					}
				}
				
			}
			return null;
		}
		
		private function get_instance_info_by_id(id:int):InstanceMapInfo {
			var arr:Array = MapMessage.getInstance().instance_infos;
			//return null;
			for each (var item:InstanceMapInfo in arr) 
			{
				if (item.id == id) {
					if (item.color == 0) {
						//没有被占领
						return null;
					}
					else {
						return item;
					}
				}
				
			}
			return null;
		}
		
		private function show_scene_tip():void {
			var t_id:int = get_id_by_bitmap(_cur_mouse_b);
			var info:SceneMapInfo = get_scene_info_by_id(t_id);
			if (null == info) {
				return;
			}
			move_scene_tip();
			_scene_place_tip.refresh(
				info.sceneName + CrotaResourceConfig.getInstance().getTextByModuleAndId('wordmap','smM_cs'), 
				CrotaResourceConfig.getInstance().getTextByModuleAndId('wordmap','smM_ssjt') + info.unionName ,
				CrotaResourceConfig.getInstance().getTextByModuleAndId('wordmap','smM_mrsy') + info.income + CrotaResourceConfig.getInstance().getTextByModuleAndId('wordmap','smM_ghcs'));
			_tips_contain.addChild(_scene_place_tip);
		}
		
		private function get_id_by_bitmap(b:Bitmap):int {
			if (null == b) {
				return -1;
			}
			for each (var item:int in _infos.keys()) 
			{
				var cur_b:Bitmap = _infos.get(item);
				if (cur_b == b) {
					return item;
				}
			}
			return -1;
		}
		
		private function show_instance_tip():void {
			var t_id:int = get_id_by_bitmap(_cur_mouse_b);
			var info:InstanceMapInfo = get_instance_info_by_id(t_id);
			if (null == info) {
				return;
			}
			move_scene_tip();
			_instance_place_tip.refresh(
				info.instanceName, 
				CrotaResourceConfig.getInstance().getTextByModuleAndId('wordmap','smM_ssjf') + info.unionName,
				CrotaResourceConfig.getInstance().getTextByModuleAndId('wordmap','smM_tgjl') + info.once+ CrotaResourceConfig.getInstance().getTextByModuleAndId('wordmap','smM_chd'),
				CrotaResourceConfig.getInstance().getTextByModuleAndId('wordmap','smM_jrsy') + info.income + CrotaResourceConfig.getInstance().getTextByModuleAndId('wordmap','smM_ghcs')
			);
			move_instance_tip();
			_tips_contain.addChild(_instance_place_tip);
		}
		
		private function move_tip():void {
			if (0 == _scene_id) {
				move_scene_tip();
			}
			else {
				move_instance_tip();
			}
		}
		
		private function move_scene_tip():void {
			if (_tips_contain.mouseX + _scene_place_tip.width > _tips_contain.stage.stageWidth) {
				_scene_place_tip.x = _tips_contain.mouseX - _scene_place_tip.width;
			}
			else{
				_scene_place_tip.x = _tips_contain.mouseX;
			}
			if (_tips_contain.mouseY + _scene_place_tip.height > _tips_contain.stage.stageHeight) {
				_scene_place_tip.y = _tips_contain.mouseY - _scene_place_tip.height;
			}
			else{
				_scene_place_tip.y = _tips_contain.mouseY;
			}
		}
		
		private function move_instance_tip():void {
			if (_tips_contain.mouseX + _instance_place_tip.width > _tips_contain.stage.stageWidth) {
				_instance_place_tip.x = _tips_contain.mouseX - _instance_place_tip.width;
			}
			else {
				_instance_place_tip.x = _tips_contain.mouseX;
			}
			if (_tips_contain.mouseY + _instance_place_tip.height > _tips_contain.stage.stageHeight) {
				_instance_place_tip.y = _tips_contain.mouseY - _instance_place_tip.height;
			}
			else{
				_instance_place_tip.y = _tips_contain.mouseY;
			}
		}
		
		private function show():void {
			var assets:AssetCenter = AssetCenter.getInstance();
			
			_window_bg.bitmapData = assets.get_img_form_pacakge('map_scene_' + _scene_id, 'map_down');
			_bg.bitmapData = assets.get_img_form_pacakge('map_scene_' + _scene_id, 'map_bg');
			_topBitmap.bitmapData = assets.get_img_form_pacakge('map_scene_' + _scene_id, 'map_top');
			
			_union_color.graphics.clear();
			_union_color.graphics.beginFill(MapMessage.getInstance().self_color);
			_union_color.graphics.drawRoundRect(0, 0, _block_w, _block_h, 1, 1);
			_union_color.graphics.endFill();
			
			_infos.clear();
			clear_sp(_show_place_contain);
			clear_sp(_mouse_place_contain);
			
			var infos:Object = MapPacePosInfo.POS_INFO[_scene_id];
			for(var index:Object in infos) 
			{
				//if (index != 1) {
					//continue;
				//}
				
				var pos:Array = infos[index] as Array;
				var bd:BitmapData = assets.get_img_form_pacakge('map_scene_' + _scene_id, index + "");
				//var b:Bitmap = new Bitmap(bd);
				//b.x = pos[0];
				//b.y = pos[1];
				
				
				//鼠标处理区域
				var tcolor:uint = 0xFF000000 + int(index);
				var mousebd:BitmapData = new BitmapData(bd.width, bd.height, true, 0);
				mousebd.threshold(bd, new Rectangle(0, 0, bd.width, bd.height), new Point(0, 0), ">", 0, tcolor);
				var mouseb:Bitmap = new Bitmap(mousebd);
				mouseb.x = pos[0];
				mouseb.y = pos[1];
				
				
				//占领高亮状态
				//var place_colir:uint = 0x80000000 + 0xFFFFFF * Math.random();
				//var placebd:BitmapData = new BitmapData(bd.width, bd.height, true, 0);
				//placebd.threshold(bd, new Rectangle(0, 0, bd.width, bd.height), new Point(0, 0), ">", 0, place_colir);
				//var placeb:Bitmap = new Bitmap(placebd);
				//placeb.x = pos[0];
				//placeb.y = pos[1];
				//_show_place_contain.addChild(placeb);
				
				
				_mouse_place_contain.addChild(mouseb);
				
				_infos.put(pos[2], mouseb);
			}
			
			if (0 == _scene_id) {
				//如果是世界地图
				_to_word_btn.set_disable(true);
				//place_player();
			}
			else {
				_to_word_btn.set_disable(false);
			}
			
			//_change_color_btn.set_disable(true);
			if (SystemDataModel.roleInfo.roleCorpsInfo.joinCorpsFlag) {
				var selfpos:int = SystemDataModel.roleInfo.roleCorpsInfo.corpsPosition;
				if (4 == selfpos) {
					_change_color_btn.set_disable(false);
				}
			}
		}
		
		private function place_player():void {
			_player_mc = AssetCenter.getInstance().get_mc_form_pacakge('map_scene_0', 'word_map_std');
			_player_mc.mouseEnabled = false;
			_player_mc.mouseChildren = false;
			_player_contain.addChild(_player_mc);
			
			var b:Bitmap = _infos.get(SystemDataModel.placeId) as Bitmap;
			if (null != b) {
				var pos_x:int = b.x + b.width / 2;
				var pos_y:int = b.y + b.height / 2;
				_player_mc.x = pos_x - CHAR_W;
				_player_mc.y = pos_y - CHAR_H;
			}
			
		}
		
		private function add_place():void {
			
		}
		
		private function clear_sp(sp:Sprite):void {
			while (sp.numChildren > 0) {
				var b:Bitmap = sp.removeChildAt(0) as Bitmap;
				if (null != b) {
					if (null != b.bitmapData) {
						b.bitmapData.dispose();
					}
				}
			}
		}
		
		public function get view():SceneMapView {
			return viewComponent as SceneMapView;
		}
		public function get contain():UIComponent {
			return view.contain;
		}
		public function get bg_contain():UIComponent {
			return view.bg;
		}
	}
}
class AreaInfo {
	public var id:int;
	public var pos_x:int;
	public var pos_y:int;
	public var tag_color:uint;
}