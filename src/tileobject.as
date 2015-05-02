package
{
	import flash.display.Sprite;

	public class tileobject extends Sprite
	{
		//is it a wall? floor? or passable (default) tile
		private const DEFAULT	:String = "default";
		private const WALL		:String = "wall";
		private const FLOOR		:String = "floor";
		public var type			:String = DEFAULT;
		
		public function tileobject()
		{
		}
	}
}