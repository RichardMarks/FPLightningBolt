package  
{
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Graphics;
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
		
		// line function uses only number variables
		// looping vars made ints
		// variable delcarations inlined
		
		// bolt graphics reference added to minimize "dot" operator function calls
		
		static private var sharedNoiseMap:Vector.<Number>;
		
		static private var boltBlur:BlurFilter;
		static private var boltGlow:GlowFilter;
		static private var boltColorTransform:ColorTransform;
		
		private var myStart:Point;
		private var myEnd:Point;
		
		private var myBolt:Sprite;
		private var myGraphics:Graphics;
		
		
		public function get Start():Point { return myStart; }
		public function get End():Point { return myEnd; }
		
		private var myColorTransform:ColorTransform;
		
		
		static private var longestLine:Number;
		private var linePointsX:Vector.<Number>;
		private var linePointsY:Vector.<Number>;
		
		//private var lineDelta:Point = new Point;
		//private var lineStep:Point = new Point;
		
		private var lineDeltaX:Number;
		private var lineDeltaY:Number;
		private var lineStepX:Number;
		private var lineStepY:Number;
		
		private var lineLength:Number;
		
		
		public function Bolt(fromX:Number, fromY:Number, toX:Number, toY:Number) 
		{
			if (sharedNoiseMap == null)
			{
				var noiseBmp:BitmapData = new BitmapData(FP.width, 1);
				noiseBmp.noise(getTimer(), 81, 183, 7, true);
				sharedNoiseMap = new Vector.<Number>(FP.width);
				
				for (var i:int = 0; i < sharedNoiseMap.length; i++)
				{
					sharedNoiseMap[i] = (noiseBmp.getPixel(i, 0) >> 16) * 0.02;//((81 + (Math.random() * 99)) >> 16) * 0.4;
				}
				noiseBmp.dispose();
				
				boltBlur = new BlurFilter(1, 1, 1);
				boltGlow = new GlowFilter(0x22CCBB, 1, 8, 8, 1, BitmapFilterQuality.MEDIUM);
				boltColorTransform = new ColorTransform(1, 4, 1, 1);
				
				longestLine = Math.max(FP.width, FP.height) * 2;
			}
			
			myBolt = new Sprite;
			myGraphics = myBolt.graphics;
			myBolt.filters = [boltBlur, boltGlow];
			
			linePointsX = new Vector.<Number>(longestLine);
			linePointsY = new Vector.<Number>(longestLine);
			myStart = new Point(fromX, fromY);
			myEnd = new Point(toX, toY);
			
			
			MakeLine();
			
		}
		
		private var counter:Number = 0;
		private var rate:Number = 2;
		
		override public function update():void 
		{
			if (++counter >= rate)
			{
				counter = 0;
			}
			else
			{
				return;
			}
			
			MakeLine();
			
			myGraphics.clear();
			myGraphics.moveTo(myStart.x, myStart.y);
			myGraphics.lineStyle(2, 0xffffff, 1);
			
			
			var r:int;
			for (var i:int = 1; i < lineLength; i++)
			{
				r = int(Math.random() * FP.width);
				linePointsX[i] += sharedNoiseMap[r];
				linePointsY[i] += sharedNoiseMap[r];
				
				myGraphics.lineTo(linePointsX[i], linePointsY[i]);
			}
			
			super.update();
		}
		
		override public function render():void 
		{
			FP.buffer.draw(myBolt, null, boltColorTransform, BlendMode.ADD);
			//FP.log("bolt dim: ", myBolt.width, myBolt.height);
			
			super.render();
		}
		
		private function MakeLine():void
		{
			var x1:Number = myStart.x, 
				y1:Number = myStart.y,
				x2:Number = myEnd.x,
				y2:Number = myEnd.y,
				partial:Number,
				current:int = 0;
			
			lineDeltaX = x2 - x1;
			lineDeltaY = y2 - y1;
			
			if (lineDeltaX < 0) { lineDeltaX = -lineDeltaX; lineStepX = -1; } else { lineStepX = 1; }
			if (lineDeltaY < 0) { lineDeltaY = -lineDeltaY; lineStepY = -1; } else { lineStepY = 1; }
			
			lineDeltaX <<= 1;
			lineDeltaY <<= 1;
			
			linePointsX[current] = x1;
			linePointsY[current] = y1;
			
			if (lineDeltaX > lineDeltaY)
			{
				partial = lineDeltaY - (lineDeltaX >> 1);
				while (x1 != x2)
				{
					if (partial >= 0)
					{
						y1 += lineStepY;
						partial -= lineDeltaX;
					}
					x1 += lineStepX;
					partial += lineDeltaY;
					current++;
					linePointsX[current] = x1;
					linePointsY[current] = y1;
				}
			}
			else
			{
				partial = lineDeltaX - (lineDeltaY >> 1);
				while (y1 != y2)
				{
					if (partial >= 0)
					{
						x1 += lineStepX;
						partial -= lineDeltaY;
					}
					y1 += lineStepY;
					partial += lineDeltaX;
					current++;
					linePointsX[current] = x1;
					linePointsY[current] = y1;
				}
			}
			
			lineLength = current;
			
		}
	}

}