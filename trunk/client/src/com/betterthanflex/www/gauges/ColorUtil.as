package com.betterthanflex.www.gauges
{
	public class ColorUtil
	{
		
		public static function getGradientColors(colors:Array, steps:uint):Array
		{
			var result:Array = new Array();
			if(steps > 0 && colors.length > 1)
			{
				var cIndex:Number = 0;
				var fromColor:Color = new Color();
				fromColor.argb = colors[cIndex];
				var toColor:Color = new Color();
				toColor.argb = colors[cIndex + 1];
				var p:Number = 0;
				for(var i:int = 0;i<steps;i++)
				{
					result.push(Color.blend(fromColor,toColor,p));
					p += 1/Math.floor(steps/(colors.length - 1));
					
					if((i+1)/(steps-1) >= (cIndex+1)/(colors.length-1))
					{
						cIndex++;
						fromColor.argb = colors[cIndex];
						toColor.argb = colors[cIndex + 1];
						p = 0;
					}
				}
			}
			else if(steps > 0 && colors.length == 1)
			{
				for(var j:int = 0;j<steps;j++)
				{
					var col:Color = new Color();
					col.argb = colors[0];
					result.push(col);
				}
				//todo just return uints. 
					
			}
			return result;
		}
	}
}