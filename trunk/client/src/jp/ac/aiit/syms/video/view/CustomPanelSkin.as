package jp.ac.aiit.syms.video.view
{
	import flash.display.Graphics;
	import mx.skins.halo.PanelSkin;
	
	public class CustomPanelSkin extends PanelSkin
	{
		override protected function updateDisplayList(w:Number,h:Number):void {
			super.updateDisplayList(w,h);
			var gfx:Graphics = this.graphics;
			gfx.beginFill(000000, this.getStyle("borderAlpha"));
			gfx.lineTo(w,h);
			gfx.lineTo(w,h-12);
			gfx.lineTo(w-12,h);
			
		}
	}
}