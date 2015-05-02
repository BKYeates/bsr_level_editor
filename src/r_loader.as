package
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	public class r_loader extends Loader
	{
		/** open directory */
		private var m_file				:File;
		
		/** assets that are attempting to load while the load state is "loading" get added to the loadQue */
		private var m_loadQue			:Vector.<Object>;
		
		/** function to call when an asset is loaded */
		private var m_callback			:Function;
		
		/** current state of the loader, ie. "loading", "ready" */
		private var m_loadState			:String;
		
		/** number of assets to load, used in conjuction with m_assetsLoaded */
		private var m_loadAmount			:int;
		
		/** all loaded assets are stored in this dictionary */
		private var m_loadedAssets		:Dictionary;
		
		/** running count of the assets loaded */
		private var m_assetsLoaded		:int;
		
		/** current file name of the loaded bitmap */
		private var m_currentAssetName	:String;
		
		/** singleton */ 		
		private static var _instance:r_loader;
		
		public function r_loader( pvt:privateclass ) {
			m_file 			= File.desktopDirectory;
			m_loadedAssets 	= new Dictionary();
			m_loadQue 		= new Vector.<Object>();
			m_loadState 		= "ready";
			this.contentLoaderInfo.addEventListener( Event.COMPLETE, HandleBytesLoaded );
		}
		
		private function LoadAsset( bytes:ByteArray ):void {
			m_loadState = "loadingAsset";
			loadBytes( bytes );
		}
		
		/** Load complete handler */
		private function HandleBytesLoaded( e:Event ):void {
			var bitmap:Bitmap = new Bitmap( (content as Bitmap).bitmapData );
			bitmap.smoothing = true;
			bitmap.name = m_currentAssetName;
			m_loadedAssets[m_currentAssetName] = bitmap;
			m_loadState = "ready";
			
			++m_assetsLoaded;
			m_callback( bitmap, m_assetsLoaded == m_loadAmount );
			
			if ( m_loadQue.length > 0 ) {
				GetAsset( m_loadQue[ 0 ].name, m_loadQue[ 0 ].bytes, m_loadQue[0].callback );
				m_loadQue.splice( 0, 1 );
			}
		}
		
		/** Return asset or load asset if it is not stored in the loadedAssets container
		*	If an asset is currently loading when GetAsset is called, we add that asset to the loadQue vector
		 * @param name - name of the file
		 * @param bytes - this editor using file stream to load assets, assets will be in AMF format ( serialized to bytearray )
		 * @param callback - sets the global callback function to call when an asset is loaded
		*/
		public function GetAsset( name:String, bytes:ByteArray, callback:Function=null ):* {
			if ( m_loadedAssets[name] ) { 
				return m_loadedAssets[name];
			}
			if ( m_loadState != "loadingAsset" ) { 
				m_callback = callback;
				m_currentAssetName = name;
				LoadAsset( bytes );
			} 
			else if ( m_loadQue.indexOf( name ) == -1 ) {
				m_loadQue.push( { name:name, bytes:bytes, callback:callback } );
			}
		}

		public function get loadedAssets():Dictionary { return m_loadedAssets; }
		public function set loadAmount( value:int ):void { m_loadAmount = value; }
		
		//singleton instance
		public static function get instance():r_loader { return _instance ? _instance : _instance = new r_loader( new privateclass() ); }
	}
}

class privateclass{}