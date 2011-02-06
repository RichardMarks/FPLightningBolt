package  
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import net.flashpunk.utils.Draw;
	/**
	 * ...
	 * @author Richard Marks
	 */
	public class LightningBolt 
	{
		private var myLastLine:Number;
		private var myLines:Vector.<Point>;
		private var myDensity:Number;
		private var myColor:uint;
		private var myThickness:Number;
		
		private var myStart:Point;
		private var myEnd:Point;
		
		public function LightningBolt(from:Point, to:Point, thickness:Number = 2, color:uint = 0x22CCBB)
		{
			myStart = new Point(from.x, from.y);
			myEnd = new Point(to.x, to.y);
			myThickness = thickness;
			myColor = color;
			
			myLines = MakeLine(from, to);
			myDensity = myLines.length;
			myLastLine = myLines.length - 1;
		}
		
		public function Render(target:BitmapData, chaos:Number):void
		{
			Draw.linePlus(myStart.x, myStart.y, myEnd.x, myEnd.y, 0xFFFF0000, 0.8, myThickness);
			
			myLines = MakeLine(myStart, myEnd);
			// start
			myLines[0].x = myStart.x;
			myLines[0].y = myStart.y;
			
			// end
			myLines[myLastLine].x = myEnd.x;
			myLines[myLastLine].y = myEnd.y;
			
			// percentage complete
			var complete:Number = (myLines[myLastLine].x - myLines[0].x) * 0.01;
			
			// displacement of first line
			myLines[1].x = myLines[0].x + complete;
			myLines[1].y = myLines[0].y + (chaos * 0.5) - (Math.random() * chaos);
			
			// render first line
			Draw.linePlus(myLines[0].x, myLines[0].y, myLines[1].x, myLines[1].y, myColor, 0.8, myThickness);
			
			var currentLine:Number = 2;
			var previousLine:Number = currentLine - 1;
			while (currentLine <= myLastLine)
			{
				previousLine = currentLine - 1;
				var d:Point = myLines[myLastLine].subtract(myLines[0]);
				
				// percentage complete
				complete = (d.x * currentLine) * 0.01;
				
				// random displacement
				var offset:Number = (1 - (2 * (Math.random() / Number.MAX_VALUE))) * 0.1 * chaos;
				
				myLines[currentLine].x = myLines[previousLine].x + offset;
				myLines[currentLine].y = myLines[previousLine].y - offset;
				
				// too much displacement?
				if (Math.abs(myLines[currentLine].y - myLines[0].y) > chaos * 0.5)
				{
					myLines[currentLine].y += -(myLines[currentLine].y - myLines[0].y) * 0.5;
				}
				
				// render line
				Draw.linePlus(myLines[previousLine].x, myLines[previousLine].y, myLines[currentLine].x, myLines[currentLine].y, myColor, 0.8, myThickness);
				currentLine++;
			}
			
			previousLine = myLastLine - 1;
			
			// render last line
			//Draw.linePlus(myLines[previousLine].x, myLines[previousLine].y, myLines[myLastLine].x, myLines[myLastLine].y, myColor, 0.8, myThickness);
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