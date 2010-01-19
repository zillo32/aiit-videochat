package com.betterthanflex.www.gauges
{
	import flash.events.EventDispatcher;
	import flash.events.Event;
	
	public class Color extends EventDispatcher
	{
		private var _alpha:uint = 255;//between 0 and 255
		private var _red:uint;//between 0 and 255
		private var _green:uint;//between 0 and 255
		private var _blue:uint;//between 0 and 255
		private var _hue:Number; //between 0 and 360 !
		private var _saturation:Number; //between 0 and 255
		private var _value:Number; //between 0 and 255
		
		/**
		 * Sets RGB value, assumes an alpha of 255 (1)
		 */
		[Bindable(event="change")]
		public function set rgb(val:uint):void
		{
			setARGB(0xFF,(val >> 16) & 0xFF,(val >> 8) & 0xFF,val & 0xFF);
		}
		
		public function get rgb():uint
		{
			var result:uint = ((_red & 0xFF) << 16) | ((_green & 0xFF) << 8) | (_blue & 0xFF);
			return result;
		}
		
		[Bindable(event="change")]
		public function set argb(val:uint):void
		{
			setARGB((val >> 24) & 0xFF,(val >> 16) & 0xFF,(val >> 8) & 0xFF,val & 0xFF);
		}
		
		public function get argb():uint
		{
			var result:uint = ((_alpha & 0xFF) << 24) | ((_red & 0xFF) << 16) | ((_green & 0xFF) << 8) | (_blue & 0xFF);
			return result;			
		}
		
		[Bindable(event="change")]
		public function set alpha(val:uint):void
		{
			setARGB(val & 0xFF,_red,_green,_blue);
		}
		
		public function get alpha():uint
		{
			return _alpha;
		}
		
		[Bindable(event="change")]
		public function set red(val:uint):void
		{
			setARGB(_alpha,val & 0xFF,_green,_blue);
		}
		
		public function get red():uint
		{
			return _red;
		}
		
		[Bindable(event="change")]
		public function set green(val:uint):void
		{
			setARGB(_alpha,_red,val & 0xFF,_blue);
		}
		
		public function get green():uint
		{
			return _green;
		}
		
		[Bindable(event="change")]
		public function set blue(val:uint):void
		{
			setARGB(_alpha,_red,_green,val & 0xFF);
		}
		
		public function get blue():uint
		{
			return _blue;
		}
		
		[Bindable(event="change")]
		public function set hue(val:uint):void
		{
			setHSV(Math.min(360,Math.max(0,val)),_saturation,_value);
		}
		
		public function get hue():uint
		{
			return _hue;
		}
		
		[Bindable(event="change")]
		public function set saturation(val:uint):void
		{
			setHSV(_hue,val & 0xFF,_value);
		}
		
		public function get saturation():uint
		{
			return _saturation;
		}
		
		[Bindable(event="change")]
		public function set value(val:uint):void
		{
			setHSV(_hue,_saturation,val & 0xFF);
		}
		
		public function get value():uint
		{
			return _value;
		}
		
		public function setHSV(h:Number,s:Number,v:Number):void
		{
			_hue = h; _saturation = s; _value = v;
			s = s/255;
			var hi:Number = Math.floor(h/60);
			var f:Number = (h/60) - hi;
			var p:Number = v*(1-s);
			var q:Number = v*(1-(f*s));
			var t:Number = v*(1-((1-f)*s));
			switch(hi)
			{
				case(0):
				{
					_red = v; _green = t; _blue = p;
					break;
				}
				case(1):
				{
					_red = q; _green = v; _blue = p;
					break;
				}
				case(2):
				{
					_red = p; _green = v; _blue = t;
					break;
				}
				case(3):
				{
					_red = p; _green = q; _blue = v;
					break;
				}
				case(4):
				{
					_red = t; _green = p; _blue = v;
					break;
				}
				case(5):
				{
					_red = v; _green = p; _blue = q;
					break;
				}
			}
			dispatchEvent(new Event("change"));
		}
		
		public function setARGB(a:uint,r:uint,g:uint,b:uint):void
		{
			_alpha = a;_red = r; _green = g; _blue = b;
			
			var max:uint = Math.max(_red,_green,_blue);
			var min:uint = Math.min(_red,_green,_blue);
			
			_saturation = (max == 0)?0:((1 - Number(min)/Number(max)) * 255);
			_value = max;
			//hue calculations
			if(max == min)
				_hue = 0;
			else if(max == _red)
				if(_green >= _blue)
					_hue = 60 * ((Number(_green) - Number(_blue))/(Number(max) - Number(min)));
				else
					_hue = (60 * ((Number(_green) - Number(_blue))/(Number(max) - Number(min)))) + 360;
			else if(max == _green)
				_hue = (60 * ((Number(_blue) - Number(_red))/(Number(max) - Number(min)))) + 120;
			else if(max == _blue)
				_hue = (60 * ((Number(_red) - Number(_green))/(Number(max) - Number(min)))) + 240;
			
			dispatchEvent(new Event("change"));
		}
	

		//a and b are the colos to blend, p is a number between 0 and 1 that specifies the position of the blend. 
		//At 0, the color returned will be equal to a, at 1, it will be equal to b
		public static function blend(a:Color,b:Color,p:Number):Color
		{
			p = Math.min(Math.max(p,0),1); //make sure p is between 0 and 1
			var col:Color = new Color();
			col.setARGB((a.alpha * (1-p)) +  (b.alpha * p),(a.red * (1 - p)) +  (b.red * p),(a.green * (1 - p)) +  (b.green * p),(a.blue * (1 - p)) +  (b.blue * p));
			return col
		}

	}
}