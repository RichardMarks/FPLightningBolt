package  
{
	import flash.geom.Point;
	import net.flashpunk.FP;
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
			//bolt = new LightningBolt(new Point(64,64), new Point(256, 256));
			
			bolt = new Bolt(new Point(64, 64), new Point(256, 256));
			
			add(bolt);
			
			super.begin();
		}
		
		override public function update():void 
		{
			bolt.End.x = FP.screen.mouseX;
			bolt.End.y = FP.screen.mouseY;
			super.update();
		}
		
		override public function render():void 
		{
			super.render();
		}
	}

}