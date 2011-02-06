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
		private var myLines:Vector.<Point>;
		
		private var myStart:Point;
		private var myEnd:Point;
		
		private var myBolt:Sprite;
		private var myNoise:BitmapData;
		
		public function get Start():Point { return myStart; }
		public function get End():Point { return myEnd; }
		
		private var myColorTransform:ColorTransform;
		
		public function Bolt(from:Point, to:Point) 
		{
			myStart = from;
			myEnd = to;
			myLines = MakeLine(from, to);
			
			
			myBolt = new Sprite;
			myBolt.filters = [new BlurFilter(1, 1, 1), new GlowFilter(0x22CCBB/*0x4411ff*/, 1, 16, 32, 4, BitmapFilterQuality.MEDIUM)];
			
			myNoise = new BitmapData(FP.width, FP.height, false, 0x000000);
			myNoise.noise(getTimer(), 81, 193, 7, true);
			myColorTransform = new ColorTransform(1, 4, 1, 1);
		}
		
		override public function update():void 
		{
			myNoise.noise(getTimer(), 81, 193, 7, true);
			
			myLines = MakeLine(myStart, myEnd);
			
			var x:Number = myStart.x;
			var y:Number = myStart.y;
			
			myBolt.graphics.clear();
			myBolt.graphics.moveTo(myStart.x, myStart.y);
			
			for (var i:Number = 1; i < myLines.length; i++)
			{
				myBolt.graphics.lineStyle(2, 0xffffff, 1);
				myLines[i].x += (myNoise.getPixel(myLines[i].x, myLines[i].y) >> 16) * 0.04;
				myLines[i].y += (myNoise.getPixel(myLines[i].x, myLines[i].y) >> 16) * 0.04;
				myBolt.graphics.lineTo(myLines[i].x, myLines[i].y);
			}
			
			super.update();
		}
		
		override public function render():void 
		{
			FP.buffer.draw(myBolt, null, myColorTransform, BlendMode.ADD);
			
			super.render();
		}
		
		private function MakeLine(from:Point, to:Point):Vector.<Point>
		{
			var x1:Number = from.x;
			var y1:Number = from.y;
			var x2:Number = to.x;
			var y2:Number = to.y;
			var line:Vector.<Point> = new Vector.<Point>();
			var partial:Number;
			var delta:Point = new Point(x2 - x1, y2 - y1);
			var step:Point = new Point;
			
			if (delta.x < 0) { delta.x = -delta.x; step.x = -1; } else { step.x = 1; }
			if (delta.y < 0) { delta.y = -delta.y; step.y = -1; } else { step.y = 1; }
			
			delta.x <<= 1;
			delta.y <<= 1;
			
			line.push(new Point(x1, y1));
			
			if (delta.x > delta.y)
			{
				partial = delta.y - (delta.x >> 1);
				while (x1 != x2)
				{
					if (partial >= 0)
					{
						y1 += step.y;
						partial -= delta.x;
					}
					x1 += step.x;
					partial += delta.y;
					line.push(new Point(x1, y1));
				}
			}
			else
			{
				partial = delta.x - (delta.y >> 1);
				while (y1 != y2)
				{
					if (partial >= 0)
					{
						x1 += step.x;
						partial -= delta.y;
					}
					y1 += step.y;
					partial += delta.x;
					line.push(new Point(x1, y1));
				}
			}
			return line;
		}
	}

}