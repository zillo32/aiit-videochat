package com.betterthanflex.www.gauges
{
	import flash.display.Graphics;
	import flash.geom.Point;
	import mx.formatters.NumberFormatter;
	import mx.formatters.NumberBaseRoundType;
	import flash.geom.Matrix;
	
	public class Util
	{
		public static var increments:Array = [0.01,0.02,0.05,0.1,0.2,0.5,1,2,5,10,15,20,30,40,50,100,200,1000,10000,100000,1000000];
		
		/**
		 * Returns an array of values that represent an optimal spread between two values.
		 * 
		 * Given the minimum, maximum and the desired number of graduations, this function finds the appropriate increment
		 * from the list of possible increments and returns an array representing a scale with that increment.
		 * 
		 * For example, given a minimum of 0 and maximum of 4.79, with 10 desired increments, the function will select 0.5 as 
		 * the increment and return the array [0,0.5,1,1.5, ...]
		 */
		public static function optimalScale(min:Number , max:Number, desiredNumPoints:Number = 5, zero:Boolean = true):Array
		{
			if(max < min)
			{
				var temp:Number = min;
				min = max;
				max = temp;
			}
			var range:Number = max - (zero?0:min);
			//var step:Number = range / desiredNumPoints;		
			var increment:Number = increments[0];
			for(var i:int = 0;i<increments.length;i++)
			{
				if(Math.abs(range - (increments[i] * desiredNumPoints)) < Math.abs(range - (increment * desiredNumPoints)))
				{
					increment = increments[i];
				}
			}

			var first:Number = Math.floor((zero?0:min) / increment) * increment;
			var last:Number = Math.ceil(max/increment) * increment;

			var nf:NumberFormatter = new NumberFormatter();
			
			nf.precision = Math.ceil(Math.log(1/increment)/Math.log(10));
			nf.rounding = NumberBaseRoundType.NEAREST;
			var graduations:Array = new Array();
			for(var j:Number = first;j <= last;j += increment)
			{
				if(increment < 1)
					graduations.push(nf.format(j));
				else
					graduations.push(String(j));
			}	
			return graduations;		
		}
		
		/**
		 * Draws a circular curve
		 * 
		 * Using the given Graphics object, this function constructs a curve that closely approximates a
		 * circular arc by using multiple Bezier curves
		 */
		public static function circCurveTo(g:Graphics,fromAngle:Number,toAngle:Number,centerx:Number,centery:Number,radius:Number,moveToStart:Boolean = true):Point
        {
            var div:Number = 7;
            var angleRange:Number = toAngle - fromAngle;
            var controlRadius:Number = radius / Math.cos(Math.abs(angleRange)/(div*2));
            var startPoint:Point = new Point(Math.round((Math.sin(fromAngle)*radius) + centerx),Math.round((-Math.cos(fromAngle)*radius) + centery));        
            if(moveToStart)
				g.moveTo(startPoint.x,startPoint.y);
				
			for(var x:int = 0;x<div;x++)
			{
				var a:Number = fromAngle + (x * angleRange/div);
               	var p2:Point = new Point(Math.sin(a + angleRange/div)* radius + centerx,-Math.cos(a + angleRange/div)* radius + centery);               
                var cp:Point = new Point(Math.sin(a + (angleRange/(div*2))) * controlRadius + centerx,-Math.cos(a + (angleRange/(div*2))) * controlRadius + centery);

                g.curveTo(cp.x,cp.y,p2.x,p2.y);
                
            }
            return startPoint;
        }
        
		/**
		 * Draws a rectangle with rounded corners at an angle.
		 * 
		 * Similar to Graphics.drawRoundRect, this function does the same thing but puts the 
		 * rectangle on an angle
		 */
		public static function drawRoundRectAtAngle(graphics:Graphics, x:Number, y:Number, width:Number, height:Number, cornerRadius:Number, angle:Number):void
		{
			var rotate:Matrix = new Matrix();
			rotate.rotate(angle);
			var nextPoint:Point;
			var controlPoint:Point;
			
			
			nextPoint = new Point(cornerRadius,0);
			nextPoint = rotate.transformPoint(nextPoint);
			graphics.moveTo(x + nextPoint.x, y + nextPoint.y);
			
			nextPoint = new Point(width - cornerRadius,0);
			nextPoint = rotate.transformPoint(nextPoint);
			graphics.lineTo(x + nextPoint.x,y + nextPoint.y);
			
			controlPoint = new Point(width, 0);
			nextPoint = new Point(width,cornerRadius);
			nextPoint = rotate.transformPoint(nextPoint);
			controlPoint = rotate.transformPoint(controlPoint);
			graphics.curveTo(x + controlPoint.x,y + controlPoint.y,x + nextPoint.x,y + nextPoint.y);
			
			nextPoint = new Point(width,height - cornerRadius);
			nextPoint = rotate.transformPoint(nextPoint);
			graphics.lineTo(x + nextPoint.x,y + nextPoint.y);
			
			controlPoint = new Point(width,height) ;
			nextPoint = new Point(width - cornerRadius,height);
			nextPoint = rotate.transformPoint(nextPoint);
			controlPoint = rotate.transformPoint(controlPoint);
			graphics.curveTo(x + controlPoint.x,y + controlPoint.y,x + nextPoint.x,y + nextPoint.y);
			
			nextPoint = new Point(cornerRadius,height);
			nextPoint = rotate.transformPoint(nextPoint);
			graphics.lineTo(x + nextPoint.x,y + nextPoint.y);
			
			controlPoint = new Point(0,height);
			nextPoint = new Point(0,height - cornerRadius);
			nextPoint = rotate.transformPoint(nextPoint);
			controlPoint = rotate.transformPoint(controlPoint);
			graphics.curveTo(x + controlPoint.x,y + controlPoint.y,x + nextPoint.x,y + nextPoint.y);
			
			nextPoint = new Point(0,cornerRadius);
			nextPoint = rotate.transformPoint(nextPoint);
			graphics.lineTo(x + nextPoint.x,y + nextPoint.y);
			
			controlPoint = new Point(0,0);
			nextPoint = new Point(cornerRadius,0);
			nextPoint = rotate.transformPoint(nextPoint);
			controlPoint = rotate.transformPoint(controlPoint);
			graphics.curveTo(x + controlPoint.x,y + controlPoint.y,x + nextPoint.x,y + nextPoint.y);
		}
	}
}