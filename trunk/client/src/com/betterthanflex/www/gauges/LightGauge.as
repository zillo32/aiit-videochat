package com.betterthanflex.www.gauges
{
	import mx.core.UIComponent;
	import flash.geom.Point;
	import mx.styles.StyleManager;
	import mx.styles.CSSStyleDeclaration;

/** Styles */
[Style(name="borderColor", type="uint", format="Color", inherit="no")]

[Style(name="borderStyle", type="String", enumeration="solid,none", inherit="no")]

[Style(name="borderThickness", type="Number", format="Length", inherit="no")]

[Style(name="lightStyle", type="String", enumeration="normal,solid", inherit="no")]

	public class LightGauge extends UIComponent
	{
		//These are the three modes that the gauge can be in
		public static const STRAIGHT:int = 0;
		public static const CURVED:int = 1;
		public static const RADIAL:int = 2;
		
		//If the gauge is in STRAIGHT mode, then it can either be horizontal or vertical
		public static const VERTICAL:int = 0;
		public static const HORIZONTAL:int = 1;	
		
		//Default Gauge is STRAIGHT and VERTICAL
		private var _shape:int = STRAIGHT;
		private var _direction:int = VERTICAL;
		
		//For RADIAL and CURVED gauges, the angle (in radians) that the gauge starts and ends
		//0° is at the top of the circle, going to Pi clockwisw and -Pi anticlockwise
		private var _angleFrom:Number = -Math.PI;
		private var _angleTo:Number = Math.PI;
		//The center and radius of the circle for RADIAL and CURVED modes
		//These are set by the setters for width and height
		private var _center:Point = new Point(100,100);;
		private var _radius:Number = 100;
		
		//Arrays of colors for off and on modes
		private var _offColors:Array = [0xFF296500,0xFF86840D,0xFFB31212];
		private var _onColors:Array = [0xFF5CE600,0xFFF1EF4C,0xFFFF1212];
		private var _offGradient:Array;
		private var _onGradient:Array;
		//The number of bars the gauge will be divided up in to 
		private var _divisions:Number = 20;
		
		//The thickness of the bars
		private var _lightThickness:Number = 10;
		private var _lightwidths:Array = [40,40];
		
		private var _value:Number = 0;
		private var _min:Number = 0;
		private var _max:Number = 10;
		
		private var _cornerRadius:Number = 3;
		private var _margin:Number = 0;
		private var _roundedCorners:Boolean = true;
		
		private static var classConstructed:Boolean = classConstruct();
		
		private static function classConstruct():Boolean 
        {
            if (!StyleManager.getStyleDeclaration("LightGauge"))
            {
                var newStyleDeclaration:CSSStyleDeclaration = new CSSStyleDeclaration();
                //Default styles
				newStyleDeclaration.setStyle("borderThickness",1);
				newStyleDeclaration.setStyle("borderStyle","solid");
				newStyleDeclaration.setStyle("borderColor",0x999999);
				newStyleDeclaration.setStyle("scalePosition","inside");
				newStyleDeclaration.setStyle("lightStyle","normal");
                StyleManager.setStyleDeclaration("LightGauge",newStyleDeclaration, true);
            }
            return true;
        }
		
		/**
		 * Constructor
		 */
		public function LightGauge():void
		{
			super();

			computeGradients();
		}
		
		/**
		 * Calculates the color and alpha of each bar in the gauge
		 * by interpolating the colors given in the onColors and 
		 * offColors arrays across the number of graduations
		 */
		private function computeGradients():void
		{		
			_offGradient = ColorUtil.getGradientColors(offColors,_divisions);
			_onGradient = ColorUtil.getGradientColors(onColors,_divisions);
		}
		
		/**
		 * This is where the magic happens
		 */
		protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			graphics.clear();
			if(getStyle("borderStyle") == "solid")
				graphics.lineStyle(getStyle("borderThickness"),getStyle("borderColor"));
				
			var gap:Number = (((_shape == RADIAL)?this.radius:((_direction == VERTICAL)?this.height:this.width)) - (2 * _margin) - (_divisions * _lightThickness)) / _divisions; //this could be negative if there are too many bars, or they are too big.

			var angleRange:Number = _angleTo - _angleFrom;
			var lightThicknessRads:Number = _lightThickness / _radius;
			var gapRadians:Number = (angleRange - (lightThicknessRads * _divisions)) / (_divisions);
			var widthAdd:Number = 0; //the amount of width to add to the width of the bar each time if the width is changing
			if(_lightwidths.length > 1){widthAdd = (_lightwidths[_lightwidths.length -1] - _lightwidths[0]) / _divisions;}
			for(var i:int = _divisions - 1;i>=0;i--)
			{
				if(i < (_divisions /(_max - _min)) * _value) 
				{
					if(getStyle("lightStyle") == "normal")
						graphics.beginFill(_onGradient[i].rgb,uint(_onGradient[i].alpha) / 255);
					else
					{
						var boundaryIndex:int = Math.ceil(((_value - _min)/(_max - _min)) * _divisions) - 1;
						graphics.beginFill(_onGradient[boundaryIndex].rgb,uint(_onGradient[boundaryIndex].alpha) / 255);
					}
				}
				else
					graphics.beginFill(_offGradient[i].rgb,uint(_offGradient[i].alpha) / 255);	
				
				var beginP:Point = new Point();
					
				if(_shape == STRAIGHT)
				{			
					if(_direction == VERTICAL)
					{
						var py:Number = height - _margin - ( (i+1) * (gap + _lightThickness) );	
						if(_roundedCorners)		
							graphics.drawRoundRect(_margin,py,(_lightwidths[0] + (i * widthAdd)),_lightThickness,_cornerRadius);
						else
							graphics.drawRect(_margin,py,(_lightwidths[0] + (i * widthAdd)),_lightThickness);
					}
					else if(_direction == HORIZONTAL)
					{
						var px:Number = _margin + ( (i+1) * (gap + _lightThickness));
						var py:Number = Math.max(_lightwidths[0],lightWidths[_lightwidths.length -1]);
						if(_roundedCorners)	
							graphics.drawRoundRect(px,py,_lightThickness,-(_lightwidths[0] + (i * widthAdd)),_cornerRadius);
						else
							graphics.drawRect(px,py,_lightThickness,-(_lightwidths[0] + (i * widthAdd)));
								
					}	
				}
				else if(_shape == CURVED)
				{
					var currentAngle:Number = _angleFrom + ( (i+1) * lightThicknessRads) + ( i * gapRadians) ;
					beginP.x = (_radius * Math.sin(currentAngle)) + _center.x;
					beginP.y = -(_radius * Math.cos(currentAngle)) + _center.y;
					
					if(_roundedCorners)
					{
						Util.drawRoundRectAtAngle(graphics,beginP.x,beginP.y,(_lightwidths[0] + (i * widthAdd)),_lightThickness,_cornerRadius,currentAngle + Math.PI/2);
					}
					else
					{
						graphics.moveTo(beginP.x,beginP.y);
						Util.circCurveTo(graphics,currentAngle,currentAngle - lightThicknessRads,_center.x,_center.y,_radius,false);
						graphics.lineTo((_radius - (_lightwidths[0] + (i * widthAdd))) * Math.sin(currentAngle - lightThicknessRads) + _center.x,-(_radius - (_lightwidths[0] + (i * widthAdd))) * Math.cos(currentAngle - lightThicknessRads) + _center.y);
						Util.circCurveTo(graphics,currentAngle - lightThicknessRads,currentAngle,_center.x,_center.y,_radius - (_lightwidths[0] + (i * widthAdd)),false);
						graphics.lineTo(beginP.x,beginP.y);
					}
				}
				else if(_shape == RADIAL)
				{
					if(angleRange == 2 * Math.PI)
					{
						graphics.drawCircle(_center.x, _center.y,((i+1) * _lightThickness) + (i * gap));
						graphics.drawCircle(_center.x, _center.y,(i * _lightThickness) + (i * gap));
					}
					else
					{
						beginP = Util.circCurveTo(graphics,angleFrom,angleTo,_center.x,_center.y, (i * _lightThickness) + (i * gap),true);
						graphics.lineTo((((i+1) * _lightThickness) + (i * gap)) * Math.sin(angleTo) + _center.x,(((i+1) * _lightThickness) + (i * gap)) * -Math.cos(angleTo)  + _center.y);
						Util.circCurveTo(graphics,angleTo,angleFrom,_center.x,_center.y, Math.round(((i+1) * _lightThickness) + (i * gap)),false);
						graphics.lineTo(beginP.x,beginP.y);
					}
				}
				graphics.endFill();
			}
		}
		
		public function set value(val:Number):void
		{
			_value = val;
			invalidateDisplayList();	
		}
		
		[Bindable]
		public function set shape(value:int):void
		{
			_shape = value;
			invalidateDisplayList();
		}
		
		public function get shape():int
		{
			return _shape;
		}
		
		[Bindable]
		public function set direction(value:int):void
		{
			_direction = value;
			invalidateDisplayList();
		}
		
		public function get direction():int
		{
			return _direction;
		}
		
		[Bindable]
		public function set radius(value:Number):void
		{
			_radius = value;
			invalidateDisplayList();
		}
		
		public function get radius():Number
		{
			return _radius;
		}
		
		[Bindable]
		public function set angleFrom(value:Number):void
		{
			_angleFrom = value;
			invalidateDisplayList();
		}
		
		public function get angleFrom():Number
		{
			return _angleFrom;
		}
		
		[Bindable]
		public function set angleTo(value:Number):void
		{
			_angleTo = value;
			invalidateDisplayList();
		}
		
		public function get angleTo():Number
		{
			return _angleTo;
		}
		
		public override function set width(value:Number):void
		{
			super.width = value;
			 _center.x = value / 2;
			_radius = Math.round(Math.min(width/2,height/2));
		}
		
		public override function set height(value:Number):void
		{
			super.height = value;
			 _center.y = value / 2;
			_radius = Math.round(Math.min(width/2,height/2));	
		} 
		
		[Bindable]
		public function set divisions(value:Number):void
		{
			_divisions = value;
			computeGradients();
			invalidateDisplayList();
		}
		
		public function get divisions():Number
		{
			return _divisions;
		}
	
		public function setColor(on:Boolean,index:int,value:uint,alpha:Number = 1):void
		{
			var arr:Array = on?onColors:offColors;
			if(index >= 0 && index < arr.length)
			{
				alpha = Math.min(1,Math.max(alpha,0));
				var hexalpha:uint = uint(alpha * 255) << 24;
				value = value & 0xFFFFFF; //wipe the alpha value from the argb uint
				arr[index] = hexalpha | value; //replace with the alpha parameter
				computeGradients();
				invalidateDisplayList();
			}
		}
		
		public function addColor(on:Boolean,value:Number,alpha:Number = 1):void
		{
			var arr:Array = on?onColors:offColors;
			alpha = Math.min(1,Math.max(alpha,0));
			var hexalpha:uint = uint(alpha * 255) << 24;
			value = value & 0xFFFFFF;
			arr.push(hexalpha | value);
			computeGradients();
			invalidateDisplayList();
		}
		
		public function removeColorAt(on:Boolean,index:int):void
		{
			var arr:Array = on?onColors:offColors;
			if(index >= 0 && index < arr.length)
			{
				arr.splice(index,1);
				computeGradients();
				invalidateDisplayList();
			}
		}

		
		[Bindable]
		public function set roundedCorners(value:Boolean):void
		{
			_roundedCorners = value;
			invalidateDisplayList();
		}
		
		public function get roundedCorners():Boolean
		{
			return _roundedCorners;
		}
		
		[Bindable]
		public function set lightThickness(value:Number):void
		{
			_lightThickness = value;
			_cornerRadius = Math.min(_cornerRadius,_lightThickness/2,_lightwidths[0]/2,_lightwidths[_lightwidths.length-1]/2);
			invalidateDisplayList();
		}
		
		public function get lightThickness():Number
		{
			return _lightThickness;
		}
		
		[Bindable]
		public function set lightWidths(value:Array):void
		{
			if(value.length > 0 && value.length <=2)
			{
				_lightwidths = value;
				_cornerRadius = Math.min(_cornerRadius,_lightThickness/2,_lightwidths[0]/2,_lightwidths[_lightwidths.length-1]/2);
				invalidateDisplayList();
			}
		}
		
		public function get lightWidths():Array
		{
			return _lightwidths;
		}
		
		[Bindable]
		public function set cornerRadius(value:Number):void
		{
			_cornerRadius = Math.min(value,_lightThickness/2,_lightwidths[0]/2,_lightwidths[_lightwidths.length-1]/2);
			invalidateDisplayList();
		}
		
		public function get cornerRadius():Number
		{
			return _cornerRadius;
		}
		
		[Bindable]
		public function set minimum(value:Number):void
		{
			_min = value;
		}
		
		public function get minimum():Number
		{
			return _min;
		}
		
		[Bindable]
		public function set maximum(value:Number):void
		{
			_max = value;
		}
		
		public function get maximum():Number
		{
			return _max;
		}
		
		[Bindable]
		public function set onColors(value:Array):void
		{
			_onColors = value;
			computeGradients();
		}
		
		public function get onColors():Array
		{
			return _onColors;
		}
		[Bindable]
		public function set offColors(value:Array):void
		{
			_offColors = value;
			computeGradients();
		}
		
		public function get offColors():Array
		{
			return _offColors;
		}

	}
}