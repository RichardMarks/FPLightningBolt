package  
{
	import flash.geom.Point;
	import net.flashpunk.FP;
	import net.flashpunk.utils.Input;
	import net.flashpunk.World;
	
	/**
	 * ...
	 * @author Richard Marks
	 */
	public class GameWorld extends World 
	{
		private var bolt:Bolt;
		
		public function GameWorld() {}
		
		override public function begin():void 
		{
		
			bolt = new Bolt(64, 64, 256, 256);
			
			add(bolt);
			
			super.begin();
		}
		
		override public function update():void 
		{
			
			if (Input.mousePressed)
			{
				add(new Bolt(bolt.Start.x, bolt.Start.y, FP.screen.mouseX, FP.screen.mouseY));
			}
			
			bolt.End.x = FP.screen.mouseX;
			bolt.End.y = FP.screen.mouseY;
			
			super.update();
		}
	}
}