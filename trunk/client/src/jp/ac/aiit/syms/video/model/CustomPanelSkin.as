package jp.ac.aiit.syms.video.model
{   
    import flash.display.Graphics;   
  
    import mx.skins.halo.PanelSkin;   
  
    public class CustomPanelSkin extends PanelSkin   
    {   
        override protected function updateDisplayList(w:Number, h:Number):void {   
            super.updateDisplayList(w,h);   
  
            var gfx:Graphics = this.graphics;   
            gfx.beginFill(this.getStyle("borderColor"),   
                            this.getStyle("borderAlpha"));   
            gfx.moveTo(this.getStyle("cornerRadius"),0);   
            gfx.lineTo(15,-10);   
            gfx.lineTo(25,0);    
        }   
    }   
}  
