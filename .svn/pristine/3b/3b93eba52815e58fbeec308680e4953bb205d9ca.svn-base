package
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class collisionobject extends Sprite
	{
		/** how many current collisions are there */
		static protected var m_numCollisions:int;
		
		public var type:String = "collidable";
		
		public function collisionobject():void {
			addEventListener( Event.ADDED, OnAdded );
		}
		
		private function OnAdded( e:Event ):void {
			removeEventListener( Event.ADDED, OnAdded );
			addEventListener( Event.REMOVED, OnRemoved );
			name = "collision_" + m_numCollisions;
			trace( "added to display list: " + name );
			++m_numCollisions;
		}
		
		private function OnRemoved( e:Event ):void {
			--m_numCollisions;
			removeEventListener( Event.REMOVED, OnRemoved );
			trace( "removed a collision box, remaining: " + m_numCollisions );
		}
	}
}