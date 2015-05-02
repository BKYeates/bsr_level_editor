package com
{
	import flash.display.Bitmap;
	import flash.utils.Dictionary;

	public class assets
	{
		[Embed(source="../../assets/icon_spawner.png")]
		static private var icon_spawner:Class;
		
		[Embed(source="../../assets/icon_items.png")]
		static private var icon_items:Class;
		
		/*[Embed(source="../../assets/icon_trigger.png")]
		static private var icon_trigger:Class;*/
		
		static private var cachedAssets:Dictionary = new Dictionary()
		
		static public function GetAsset( name:String ):Bitmap {
			if ( !cachedAssets[ name ] ) {
				cachedAssets[ name ] = new assets[ name ]();
			}
			return cachedAssets[ name ];
		}
	}
}