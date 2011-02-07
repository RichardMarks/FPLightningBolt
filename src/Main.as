package 
{
	import net.flashpunk.Engine;
	import net.flashpunk.FP;
	import net.hires.debug.Stats;
	
	/**
	 * ...
	 * @author Richard Marks
	 */
	public class Main extends Engine 
	{
		
		public function Main():void 
		{
			super(800, 600);
		}
		
		override public function init():void 
		{
			//FP.stage.addChild(new Stats);
			
			FP.console.enable();
			FP.world = new GameWorld;
			super.init();
		}
	}
}