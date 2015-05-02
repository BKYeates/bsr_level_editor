package
{
	import flash.display.Sprite;
	import flash.events.Event;

	/** item */
	public class items extends Sprite {
		/*===============
		PRIVATE
		===============*/
		
		/*===============
		PROTECTED
		===============*/
		static protected var numItems:int;
		
		/*===============
		PUBLIC
		===============*/
		public var type:String;
		
		/*===============
		CONSTANTS
		===============*/
		
		public function items( size:int )
		{
			graphics.lineStyle(2, 0xFFFF00);
			graphics.beginFill(0xFFFF00,1);
			graphics.drawRect( 0, 0, size, size );
			addEventListener( Event.ADDED_TO_STAGE, OnAdded );
			addEventListener( Event.REMOVED_FROM_STAGE, OnRemoved );
		}
		
		private function OnAdded( e:Event ):void {
			name = "item_" + numItems;
			++numItems;
		}
		
		private function OnRemoved( e:Event ):void {
			--numItems;
		}
		
		/*========================================================================================
		ANCILLARY
		========================================================================================*/
		
	}
}