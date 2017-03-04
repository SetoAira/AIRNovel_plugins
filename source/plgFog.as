/*
 * plgFog
 * AIRNovel用 Fog表示プラグイン
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
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.geom.Matrix;

	public final class plgFog extends Sprite {
		private var	AnLib		:Object		= null;
		
		private var dx	:Number =0;
		private var dy	:Number =0;
		private var _tx	:Number =0;
		private var _ty	:Number =0;
		private var r_height:Number =0;
		private var r_width:Number =0;
		private var bmd	:BitmapData =null;

		public function init(hArg:Object):Boolean {
			AnLib = hArg.AnLib;
			if (AnLib == null) {hArg.ErrMes = "AnLib == null"; return false;}

			const addTag:Function = AnLib.addTag;
			if (addTag == null) {hArg.ErrMes = "addTag == null"; return false;}

			if (! addTag("fog", fog)) {
				hArg.ErrMes = "addTag [fog] err.";
				return false;
			}

			if (! addTag("tile", tile)) {
				hArg.ErrMes = "addTag [tile] err.";
				return false;
			}

			if (! addTag("clear_fog", clear_fog)) {
				hArg.ErrMes = "addTag [clear_fog] err.";
				return false;
			}

			return true;
		}

		//Fogの準備
		private function fog(hArg:Object):Boolean {
			if (! hArg.layer) {AnLib.putErrMes("[fog] layerは必須です。");return false;}
			clear_fog(hArg);
			var layer:String = hArg.layer;
			AnLib.callTag("lay", {"layer":layer, visible:true,page:"back",top:0,left:0});
			AnLib.callTag("plugin",{top:AnLib.argChk_Num(hArg, "top",0),left:AnLib.argChk_Num(hArg, "left",0), visible:true, name:"plgFog", ride:layer});
						
			//1フレームでの移動量計算
			dx = AnLib.argChk_Num(hArg, "dx", 0) / AnLib.getVal("const.flash.display.Stage.frameRate");
			dy = AnLib.argChk_Num(hArg, "dy", 0) / AnLib.getVal("const.flash.display.Stage.frameRate");
			
			_tx = _ty = 0;
			
			r_height = AnLib.argChk_Num(hArg, "height",AnLib.getVal("const.flash.display.Stage.stageHeight"));
			r_width = AnLib.argChk_Num(hArg, "width",AnLib.getVal("const.flash.display.Stage.stageWidth"));

			bmd = new BitmapData(AnLib.getLayerDO(layer, false).width, AnLib.getLayerDO(layer, false).height, true, 0x00000000);
			AnLib.getSnapshot(bmd, {"layer":layer, page:"back"});
			
			var matrix:Matrix = new Matrix (1,0,0,1,_tx,_ty);
						
			//描画
			this.graphics.clear();
			
			this.graphics.beginBitmapFill(bmd, matrix, true);
			this.graphics.drawRect(0,0, r_width, r_height);
			this.graphics.endFill();
			
			this.addEventListener(Event.ENTER_FRAME, drawFog);

			return false;
		}
	
		//Tile
		private function tile(hArg:Object):Boolean {
			if (! hArg.layer) {AnLib.putErrMes("[tile] layerは必須です。");return false;}
			clear_fog(hArg);
			var layer:String = hArg.layer;

			AnLib.callTag("lay", {"layer":layer, visible:true,page:"back",top:0,left:0});
						
			var tx:int = AnLib.argChk_Num(hArg, "tx", 0);
			var ty:int = AnLib.argChk_Num(hArg, "ty", 0);
			
			bmd = new BitmapData(AnLib.getLayerDO(layer, false).width, AnLib.getLayerDO(layer, false).height, true, 0x00000000);
			AnLib.getSnapshot(bmd, {"layer":layer, page:"back"});
			
			var matrix:Matrix = new Matrix (1,0,0,1,tx,ty);
						
			//描画
			this.graphics.clear();
			
			this.graphics.beginBitmapFill(bmd, matrix, true);
			this.graphics.drawRect(0,0, AnLib.argChk_Num(hArg, "width",AnLib.getVal("const.flash.display.Stage.stageWidth")), AnLib.argChk_Num(hArg, "height",AnLib.getVal("const.flash.display.Stage.stageHeight")));
			this.graphics.endFill();
			
			AnLib.callTag("plugin",{top:AnLib.argChk_Num(hArg, "top",0),left:AnLib.argChk_Num(hArg, "left",0), visible:true, name:"plgFog", ride:layer});

			return false;
		}
	
		//Fogの消去
		private function clear_fog(hArg:Object):Boolean {
			//Fogが存在していれば廃棄処理
			if (this.numChildren!=0) {
				this.graphics.clear();
				bmd.dispose();
				bmd = null;
			}
		
			AnLib.callTag("plugin",{visible:false,name:"plgFog"});
		
			return false;
		}
		
		//Fogの表示
		private function drawFog(e:Event):void {
					
			//移動量の計算
			const old_tx:int = _tx;
			_tx = _tx + dx;
			if (_tx >= bmd.width || - _tx >= bmd.width) _tx = 0;
			var tx:int = _tx;
			
			const old_ty:int = _ty;
			_ty = _ty + dy;
			if (_ty >= bmd.height || - _ty >= bmd.height) _ty = 0;
			var ty:int = _ty;
			
			//描画
			if (tx != old_tx || ty != old_ty){
				var matrix:Matrix = new Matrix (1,0,0,1,tx,ty);
			
				this.graphics.clear();
			
				this.graphics.beginBitmapFill(bmd, matrix);
				this.graphics.drawRect(0,0, r_width, r_height);
				this.graphics.endFill();
			}
		
			return;
		}

	}
}
