/*
 * plgLetPlus
 * AIRNovel用 transition強化プラグイン
 * 
 * Licensed under the MIT License
 * 
 * Copyright (c) 2012 SetoAira (ansawaro.wy5.org)
 * 
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation files
 * (the "Software"), to deal in the Software without restriction,
 * including without limitation the rights to use, copy, modify, merge,
 * publish, distribute, sublicense, and/or sell copies of the Software,
 * and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
 * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 * 
 */
package {
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer 
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	public final class plgTransPlus extends Sprite {
		private var	AnLib		:Object		= null;
		
		private var ed:EventDispatcher;
		private var s_width:int, s_height:int;

		public function init(hArg:Object):Boolean {
			AnLib = hArg.AnLib;
			if (AnLib == null) {hArg.ErrMes = "AnLib == null"; return false;}

			const addTag:Function = AnLib.addTag;
			if (addTag == null) {hArg.ErrMes = "addTag == null"; return false;}

			if (! addTag("trans_plus", trans_plus)) {
				hArg.ErrMes = "addTag [trans_plus] err.";
				return false;
			}
			if (! addTag("wtp", wtp)) {
				hArg.ErrMes = "addTag [wtp] err.";
				return false;
			}

			return true;
		}

		private function trans_plus(hArg:Object):Boolean {
			var time:int = AnLib.argChk_Num(hArg,"time",500);
			s_width = AnLib.getVal("const.flash.display.Stage.stageWidth");//画面幅
			s_height = AnLib.getVal("const.flash.display.Stage.stageHeight");//画面高さ

			
			//time20以下もしくは、スキップ中でskip=trueの場合は即終了とする。
			if ((AnLib.argChk_Boolean(hArg,"skip",false) && AnLib.getVal("an.skip.enabled")) || (time <= 20)){
				useTrans(hArg);
				return true;
			}

			if (! "layer" in hArg){
				throw ("[trans_plus]layerは必須です。");
				return false;
			}
			
			var bm_f:Bitmap = new Bitmap(new BitmapData(s_width, s_height, true, 0x00000000));	//表
			var bm_b:Bitmap = new Bitmap(new BitmapData(s_width, s_height, true, 0x00000000));	//裏
			
			var _trans:Boolean = false;//最後にトランスの必要があるかどうか
			
			//プラグインを潜り込ませる位置決定用に、関係レイヤとプラグインを集める
			var t_layer:String = hArg.layer;
			if ("c_flayer"in hArg) t_layer = t_layer+","+hArg.c_flayer
;
			var t_plg:String = "";
			if ("c_plugin"in hArg) t_plg = hArg.c_plugin;
			if ("plugin"in hArg) t_plg =("c_plugin"in hArg)? t_plg+","+hArg.plugin: hArg.plugin;

			//このプラグインの位置等初期化
			AnLib.callTag("plugin",{name:"plgTransPlus", top:0, left:0, visible:false, float:true, alpha:1,scale_x:1.0,scale_y:1.0, rotation:0});
			
			hArg.ease = hArg.ease || "Linear.easeInOut";
			
			if (hArg.type.substr(0,5)=="color"){
				const rect:Rectangle = new Rectangle(0, 0, s_width, s_height);
				const s_color:String = hArg.color || "0x000000";
				const _color:Number = 0xff000000+parseInt(s_color);
			}

			//タイプ別に動作設定
			switch (hArg.type) {
				case "color"://画面一色塗り
					bm_f.x=bm_f.y=0;
					bm_f.bitmapData.lock();					
					bm_f.bitmapData.fillRect(rect, _color);
					bm_f.bitmapData.unlock();
					this.addChild(bm_f);
					AnLib.callTag("plugin",{name:"plgTransPlus", top:0, left:0, visible:true});
					
					useTrans(hArg);
					break;
					
				case "colorfIn"://画面一色塗り　裏表示時にフェード
					bm_f.x=bm_f.y=0;
					bm_f.bitmapData.lock();					
					bm_f.bitmapData.fillRect(rect, _color);
					bm_f.bitmapData.unlock();
					this.addChild(bm_f);
					AnLib.callTag("plugin",{name:"plgTransPlus", top:0, left:0, visible:true});
					
					useTrans(hArg);
					hArg.alpha = 0;
					goTween(hArg);
					break;
				
				case "colorfOut"://画面一色塗り　表消すときにフェード
					bm_f.x=bm_f.y=0;
					bm_f.bitmapData.lock();					
					bm_f.bitmapData.fillRect(rect, _color);
					bm_f.bitmapData.unlock();
					this.addChild(bm_f);
					AnLib.callTag("plugin",{name:"plgTransPlus", top:0, left:0, visible:true, alpha:0});
					
					_trans=true;
					hArg.alpha = 1;
					goTween(hArg);
					break;
										
				case "colorfInOut"://画面一色塗り　両方フェード
					bm_f.x=bm_f.y=0;
					bm_f.bitmapData.lock();					
					bm_f.bitmapData.fillRect(rect, _color);
					bm_f.bitmapData.unlock();
					this.addChild(bm_f);
					AnLib.callTag("plugin",{name:"plgTransPlus", top:0, left:0, visible:true, alpha:0});
					AnLib.callTag("tsy_seq_new",{seq:"colorf"});
					AnLib.callTag("tsy_seq_push",{seq:"colorf",alpha:1,time:time/2,plugin:"plgTransPlus",ease:"Linear.easeInOut"});
					AnLib.callTag("tsy_seq_push",{seq:"colorf",alpha:0,time:time/2,plugin:"plgTransPlus",ease:"Linear.easeInOut"});
					AnLib.callTag("tsy_seq_start",{seq:"colorf"});
					var c_timer:Timer = new Timer(time/2, 1);
					c_timer.addEventListener(TimerEvent.TIMER_COMPLETE, function(e:TimerEvent):void{
						useTrans(hArg);
					});
					c_timer.start();			
					break;
										
				case "fadeIn"://裏をssしてフェードする。		
					bm_b.x=bm_b.y=0;
					bm_b.bitmapData = ssBack(hArg,t_layer,t_plg);
					AnLib.callTag("plugin",{name:"plgTransPlus", top:0, left:0, visible:true, alpha:0,index:getTopLay(t_layer, t_plg)});			
					this.addChild(bm_b);
					_trans = true;
					hArg.alpha=1;
					goTween(hArg);
					break;					
				
				case "fade":
				case "fadeOut"://表をssしてフェードする。		
					AnLib.callTag("plugin",{name:"plgTransPlus", top:0, left:0, visible:true, index:getTopLay(t_layer, t_plg)});			
					bm_f.x=bm_f.y=0;
					AnLib.getSnapshot(bm_f.bitmapData,{layer:t_layer,page:"fore",plugin:t_plg});

					this.addChild(bm_f);
					useTrans(hArg);
					hArg.alpha=0;
					goTween(hArg);
					break;					
					
				case "zoomIn"://裏を拡大縮小して表示する
					var i_scale:Number = AnLib.argChk_Num(hArg,"scale",0.5);
					bm_b.bitmapData = ssBack(hArg,t_layer,t_plg);
					bm_b.x=bm_b.y=0;
					this.addChild(bm_b);
					AnLib.callTag("plugin",{name:"plgTransPlus", top:s_height*(1-i_scale)/2, left:s_width*(1-i_scale)/2, visible:true, index:getTopLay(t_layer, t_plg), alpha:AnLib.argChk_Num(hArg,"alpha",0.5),scale_x:i_scale,scale_y:i_scale});			
					_trans=true;
					
					hArg.x=hArg.y=0;
					hArg.alpha = hArg.scaleX = hArg.scaleY =1.0;
					goTween(hArg);
					break;
					
				case "zoomOut"://表を拡大縮小して消す
					var o_scale:Number = AnLib.argChk_Num(hArg,"scale",0.5);
					AnLib.callTag("plugin",{name:"plgTransPlus", top:0, left:0, visible:true, index:getTopLay(t_layer, t_plg)});			
					bm_f.x=bm_f.y=0;
					AnLib.getSnapshot(bm_f.bitmapData,{layer:t_layer,page:"fore",plugin:t_plg});
					this.addChild(bm_f);

					useTrans(hArg);
					hArg.x = s_width*(1-o_scale)/2;
					hArg.y = s_height*(1-o_scale)/2;
					hArg.alpha = AnLib.argChk_Num(hArg,"alpha",0.5);
					hArg.scaleX = hArg.scaleY = o_scale;
					goTween(hArg);
					break;
					
				case "scrollIn"://裏をスクロースしてくる
					switch (hArg.course) {
						case "TtoB": hArg.top = -s_height;
							hArg.left = 0;
							break;
						case "BtoT": hArg.top = s_height;
							hArg.left = 0;
							break;
						case "LtoR": hArg.top = 0;
							hArg.left = -s_width;
							break;
						case "RtoL": hArg.top = 0;
							hArg.left = s_width;
							break;
						default: 
							throw ("[trans_plus]不正なcourseです。");
							break;
					}
					hArg.x = 0;
					hArg.y = 0;
					bm_b.bitmapData = ssBack(hArg,t_layer,t_plg);
					bm_b.x=bm_b.y=0;
					this.addChild(bm_b);
					AnLib.callTag("plugin",{name:"plgTransPlus",visible:true, top:hArg.top, left:hArg.left,index:getTopLay(t_layer, t_plg)});										
					_trans=true;
					goTween(hArg);
					break;
				
				case "scrollOut"://表をスクロースして出す
				case "scrollInOut"://表裏ともスクロール
					switch (hArg.course) {
						case "TtoB": hArg.y = s_height;
							hArg.x = 0;
							break;
						case "BtoT": hArg.y = -s_height;
							hArg.x = 0;
							break;
						case "LtoR": hArg.y = 0;
							hArg.x = s_width;
							break;
						case "RtoL": hArg.y = 0;
							hArg.x = -s_width;
							break;
						default: 
						throw ("[trans_plus]不正なcourseです。");
							break;
					}
					hArg.ease = "Linear.easeNone";

					if (hArg.type == "scrollInOut"){
						bm_b.bitmapData = ssBack(hArg,t_layer,t_plg);
						bm_b.x = -hArg.x;
						bm_b.y = -hArg.y;
						this.addChild(bm_b);
					}

					bm_f.x=bm_f.y=0;
					AnLib.getSnapshot(bm_f.bitmapData,{layer:t_layer,page:"fore",plugin:t_plg});

					this.addChild(bm_f);
					AnLib.callTag("plugin",{name:"plgTransPlus", top:0, left:0, visible:true, index:getTopLay(t_layer, t_plg)});			
					if (hArg.type == "scrollOut"){
						useTrans(hArg);
					} else {
						_trans = true;
						if (hArg.h_layer) changeLayer(false, hArg.h_layer);
					}

					goTween(hArg);
					break;
				
				case "tweenIn"://裏を表示するTween指定
					hArg.name = "plgTransPlus";
					hArg.visible = true;
					hArg.index = getTopLay(t_layer, t_plg);
					bm_b.bitmapData = ssBack(hArg,t_layer,t_plg);
					bm_b.x=bm_b.y=0;
					this.addChild(bm_b);
					AnLib.callTag("plugin",hArg);										
					_trans=true;
					hArg.x = hArg.y = hArg.rotation = 0;
					hArg.scaleX = hArg.scaleY = hArg.alpha =1.0;
					goTween(hArg);
					break;
					
				case "tweenOut"://表を消すTween指定
					bm_f.x=bm_f.y=0;
					AnLib.getSnapshot(bm_f.bitmapData,{layer:t_layer,page:"fore",plugin:t_plg});

					this.addChild(bm_f);
					AnLib.callTag("plugin",{name:"plgTransPlus", top:0, left:0, visible:true, index:getTopLay(t_layer, t_plg)});
					useTrans(hArg);
					hArg.scaleX = AnLib.argChk_Num(hArg,"scale_x",1.0);
					hArg.scaleY = AnLib.argChk_Num(hArg,"scale_y",1.0);
					hArg.x = AnLib.argChk_Num(hArg,"left",0);
					hArg.y = AnLib.argChk_Num(hArg,"top",0)	
					goTween(hArg);
					break;

				default:		
					throw ("[trans_plus]不正なtypeです。");
					return false;
			}
			
			ed = new EventDispatcher();
			
			var timer:Timer = new Timer(time, 1);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, function(e:TimerEvent):void{
				ed.dispatchEvent(new Event(Event.COMPLETE));
				if ((hArg.type == "scrollInOut") && (hArg.h_layer)) changeLayer(true, hArg.h_layer);
				if (_trans) useTrans(hArg);
				AnLib.callTag("plugin",{name:"plgTransPlus",visible:false});
				for (var i:int=0;i<	this.numChildren; i++){
					this.removeChildAt(0);
				}
				bm_f.bitmapData = null;
				bm_b.bitmapData = null;
				ed =null;
			});
			timer.start();			
			return false
		}
		
		private function wtp(hArg:Object):Boolean{
			if (ed==null) return false;
			return AnLib.waitCustomEvent(
				function ():void {}
			,	ed as IEventDispatcher
			,	false
			);
		}

		private function useTrans(hArg:Object):void{
			AnLib.callTag("trans",{layer:hArg.layer, time:0});
			AnLib.callTag("wt",{});
			changeVisible(hArg.c_flayler
, hArg.c_plugin);
			return;
		}			

		private function changeVisible(htmls:String, plugins:String):void{
			var name:String;
			var len:uint, i:uint;
			
			if (htmls){
				const h_vct:Vector.<String> = Vector.<String>(htmls.split(","));
				len = h_vct.length;
				for (i=0; i<len; ++i) {
					name = h_vct[i];
					AnLib.callTag("lay",{layer:name, visible:!AnLib.getVal("const.an.lay."+name+".fore.visible")});
				}
			}
			if (plugins){	
				const p_vct:Vector.<String> = Vector.<String>(plugins.split(","));
				len = p_vct.length;
				var dsp:DisplayObject;
				for (i=0; i<len; ++i) {
					name = p_vct[i];
					dsp = AnLib.getPluginDO(name);
					AnLib.callTag("plugin",{name:name, visible:!AnLib.getVal("const.an.plg."+name+".visible"), top:dsp.y, left:dsp.x});
				}
			}
			return;
		}
		
		private function getTopLay(layers:String, plg:String):int{
			var name:String;
			var len:uint, i:uint,top:uint=0;
			
			const h_vct:Vector.<String> = Vector.<String>(layers.split(","));
			len = h_vct.length;
			for (i=0; i<len; ++i) {
				name = h_vct[i];
				if (top < stage.getChildIndex(AnLib.getLayerDO(name,true))){
					top = stage.getChildIndex(AnLib.getLayerDO(name,true));
				}
				if (top < stage.getChildIndex(AnLib.getLayerDO(name,false))){
					top = stage.getChildIndex(AnLib.getLayerDO(name,false));
				}
			}
			
			if (plg == "") return top + 1;
			
			const p_vct:Vector.<String> = Vector.<String>(plg.split(","));
			len = p_vct.length;
			for (i=0; i<len; ++i) {
				name = p_vct[i];
				if (top < stage.getChildIndex(AnLib.getPluginDO(name))){
					top = stage.getChildIndex(AnLib.getPluginDO(name));
				}
			}
			return top + 1;
		}
		
		private function ssBack(hArg:Object,t_layer:String, t_plg:String):BitmapData{
					AnLib.callTag("plugin",{name:"plgTransPlus", top:0, left:0, visible:true});
					var bm_d:Bitmap = 	new Bitmap(new BitmapData(s_width, s_height, true, 0x00000000));
					bm_d.x=bm_d.y=0;
					AnLib.getSnapshot(bm_d.bitmapData,{page:"fore",plugin:t_plg});
					this.addChild(bm_d);
					var bmd:BitmapData = new BitmapData(s_width, s_height, true, 0x00000000);
					changeVisible(hArg.c_flayler
, hArg.c_plugin);
					AnLib.getSnapshot(bmd,{layer:t_layer,page:"back",plugin:t_plg});
					changeVisible(hArg.c_flayler
, hArg.c_plugin);
					AnLib.callTag("plugin",{name:"plgTransPlus", top:0, left:0, visible:false});			
									
					this.removeChild(bm_d);
					bm_d.bitmapData = null;
					return bmd;
		}
		
		private function changeLayer(visible:Boolean, layer:String):void{
			const vct:Vector.<String> = Vector.<String>(layer.split(","));
			const len:uint = vct.length;
			var name:String;
			for (var i:uint=0; i<len; ++i) {
				name = vct[i];
				if (name.substr(0, 4) == "plg:") {
					const pname:String = name.substr(4);
					AnLib.callTag("plugin",{name:pname,visible:visible});
					continue;
				}
				if (!visible) AnLib.callTag("lay",{layer:name,visible:false});
			}
			return;
		}
		
		private function goTween(hArg:Object):void{
			var layer:String = hArg.layer;
			var _plugin:String = hArg.plugin;
			hArg.layer = null;
			hArg.plugin = "plgTransPlus";
			AnLib.callTag("tsy",hArg);
			hArg.layer = layer;
			hArg.plugin = _plugin;
			return;
		}
	}
}
