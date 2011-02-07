package  
{
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.utils.getTimer;
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	/**
	 * ...
	 * @author Richard Marks
	 */
	public class Bolt extends Entity
	{
		// optimizations
		// shared noise map for all bolts
		// noise map created once
		// shared filters for all bolts
		// shared color transform for all bolts
		
		// noise map is now linear vector of values
		// noise map contains pre-calculated offset
		
		// moved linestyle outside forloop
		
		// bolt uses a single fixed-size vector instead of creating new vectors every frame
		// line function creates vars once
		
		// constructor uses numbers not points
		
		static private var sharedNoiseMap:Vector.<Number>;
		
		static private var boltBlur:BlurFilter;
		static private var boltGlow:GlowFilter;
		static private var boltColorTransform:ColorTransform;
		
		private var myLines:Vector.<Point>;
		
		private var myStart:Point;
		private var myEnd:Point;
		
		private var myBolt:Sprite;
		
		
		public function get Start():Point { return myStart; }
		public function get End():Point { return myEnd; }
		
		private var myColorTransform:ColorTransform;
		
		
		static private var longestLine:Number;
		private var linePointsX:Vector.<Number>;
		private var linePointsY:Vector.<Number>;
		private var lineDelta:Point = new Point;
		private var lineStep:Point = new Point;
		private var lineLength:Number;
		
		
		public function Bolt(fromX:Number, fromY:Number, toX:Number, toY:Number) 
		{
			if (sharedNoiseMap == null)
			{
				var noiseBmp:BitmapData = new BitmapData(FP.width, 1);
				noiseBmp.noise(getTimer(), 81, 183, 7, true);
				sharedNoiseMap = new Vector.<Number>(FP.width);
				
				for (var i:Number = 0; i < sharedNoiseMap.length; i++)
				{
					sharedNoiseMap[i] = (noiseBmp.getPixel(i, 0) >> 16) * 0.04;//((81 + (Math.random() * 99)) >> 16) * 0.4;
				}
				noiseBmp.dispose();
				
				boltBlur = new BlurFilter(1, 1, 1);
				boltGlow = new GlowFilter(0x22CCBB, 1, 8, 8, 1, BitmapFilterQuality.MEDIUM);
				boltColorTransform = new ColorTransform(1, 4, 1, 1);
				
				longestLine = Math.max(FP.width, FP.height) * 2;
			}
			
			myBolt = new Sprite;
			myBolt.filters = [boltBlur, boltGlow];
			
			linePointsX = new Vector.<Number>(longestLine);
			linePointsY = new Vector.<Number>(longestLine);
			lineDelta = new Point;
			lineStep = new Point;
			
			myStart = new Point(fromX, fromY);
			myEnd = new Point(toX, toY);
			
			MakeLine();
		}
		
		override public function update():void 
		{
			MakeLine();
			
			myBolt.graphics.clear();
			myBolt.graphics.moveTo(myStart.x, myStart.y);
			
			myBolt.graphics.lineStyle(2, 0xffffff, 1);
			
			var r:Number;
			for (var i:Number = 1; i < lineLength; i++)
			{
				r = int(Math.random() * FP.width);
				linePointsX[i] += sharedNoiseMap[r];
				linePointsY[i] += sharedNoiseMap[r];
				
				myBolt.graphics.lineTo(linePointsX[i], linePointsY[i]);
			}
			
			super.update();
		}
		
		override public function render():void 
		{
			FP.buffer.draw(myBolt, null, boltColorTransform, BlendMode.ADD);
			
			super.render();
		}
		
		private function MakeLine():void
		{
			
			var x1:Number = myStart.x;
			var y1:Number = myStart.y;
			var x2:Number = myEnd.x;
			var y2:Number = myEnd.y;

			var partial:Number;
			var current:Number = 0;
			
			lineDelta.x = x2 - x1;
			lineDelta.y = y2 - y1;
			
			if (lineDelta.x < 0) { lineDelta.x = -lineDelta.x; lineStep.x = -1; } else { lineStep.x = 1; }
			if (lineDelta.y < 0) { lineDelta.y = -lineDelta.y; lineStep.y = -1; } else { lineStep.y = 1; }
			
			lineDelta.x <<= 1;
			lineDelta.y <<= 1;
			
			linePointsX[current] = x1;
			linePointsY[current] = y1;
			
			if (lineDelta.x > lineDelta.y)
			{
				partial = lineDelta.y - (lineDelta.x >> 1);
				while (x1 != x2)
				{
					if (partial >= 0)
					{
						y1 += lineStep.y;
						partial -= lineDelta.x;
					}
					x1 += lineStep.x;
					partial += lineDelta.y;
					current++;
					linePointsX[current] = x1;
					linePointsY[current] = y1;
				}
			}
			else
			{
				partial = lineDelta.x - (lineDelta.y >> 1);
				while (y1 != y2)
				{
					if (partial >= 0)
					{
						x1 += lineStep.x;
						partial -= lineDelta.y;
					}
					y1 += lineStep.y;
					partial += lineDelta.x;
					current++;
					linePointsX[current] = x1;
					linePointsY[current] = y1;
				}
			}
			
			lineLength = current;
		}
	}

}