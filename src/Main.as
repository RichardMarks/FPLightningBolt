package 
{
	import net.flashpunk.Engine;
	import net.flashpunk.FP;
	
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
			FP.world = new GameWorld;
			super.init();
		}
	}
}