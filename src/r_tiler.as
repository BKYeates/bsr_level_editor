package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;

	/*========================================================================================
	r_tiler handles tile placement
	========================================================================================*/
	public class r_tiler extends Sprite
	{
		/*===============
		PUBLIC
		===============*/
		public var background:Sprite;
		public var midground:Sprite;
		public var foreground:Sprite;
		public var collisions:Sprite;
		public var spawners:Sprite;
		public var grid:Sprite;
		
		/** the list of column positions (x) */
		public var gridColumns:Vector.<Number>;
		/** the list of row positions */
		public var gridRows:Vector.<Number>;
		
		/** the current grid unit size */
		public var unitSize:int;
		
		/*===============
		PRIVATE
		===============*/
		/** active layer can be background, midground, or foreground */
		private var m_activeLayer:Sprite;
		
		/** container holding the current tile */
		private var m_tileContainer:Sprite;
		
		/** undo container has all the list of steps taken */
		private var m_undoSteps:Array;
		
		/** redo container has any spliced undo steps*/
		private var m_redoSteps:Vector.<String>;
		
		/** active keys */
		private var m_keys:Dictionary;
		
		/** tile we have currently selected */
		private var m_currentBitmap:Bitmap;
		
		/** tile we have currently placed down in the editor */
		private var m_focusTile:*;
		
		/** when space is pressed origin gets set to the mouse position */
		private var m_origin:Point;
		
		/** translations should move according to the grid unit size */
		private var m_snapToGrid:Boolean;
		
		/** keeps the mouse states organized so we can determine if we are drawing collisions or tiles */
		private var m_mouseState:String;
		
		/** when we are drawing collisions, track the current collision box with this variable */
		private var m_activeCollisionBox:Sprite;
		
		/*===============
		STATIC
		===============*/
		/** stage reference */
		static private var m_stage:Stage;
		
		/** singleton */
		static private var sm_instance:r_tiler;
		
		/*===============
		CONSTANTS
		===============*/
		private const DOWN	:String = "down";
		private const UP	:String = "up";
		
		/** singleton constructor */
		public function r_tiler( pvt:privateclass ) {
			m_tileContainer = new Sprite();
			m_undoSteps 	= [];
			m_redoSteps 	= new Vector.<String>;
			m_keys 	= new Dictionary();
			gridColumns 	= new Vector.<Number>;
			gridRows 		= new Vector.<Number>;
			m_mouseState	= UP;
		}
		
		/** Clear the container and add a new selected bitmap to it */
		public function UpdateActiveTile( bitmap:Bitmap ):void {
			ClearTileContainer();
			m_currentBitmap = bitmap;
			var b:Bitmap = new Bitmap( bitmap.bitmapData );
			b.name = bitmap.name;
			m_tileContainer.addChild( b );
			while(m_tileContainer.width > 300 || m_tileContainer.height > 300 && m_tileContainer.scaleX > 0.2) {
				m_tileContainer.scaleX -= 0.1;
				m_tileContainer.scaleY -= 0.1;
			}
			m_focusTile = null;
		}
		
		public function OnSpawnerSelected():void {
			ClearTileContainer();
			var spawn:spawner = new spawner( unitSize );
			m_tileContainer.addChild( spawn );
			m_focusTile = spawn;
		}
		
		public function OnItemSelected():void {
			ClearTileContainer();
			var item:items = new items( unitSize );
			m_tileContainer.addChild( item );
			m_focusTile = item;
		}
		
		/** Clear the container holding the tile */
		private function ClearTileContainer():void {
			m_tileContainer.removeEventListener( MouseEvent.CLICK, OnTilerClick );
			if ( m_tileContainer.numChildren >  0 ) { m_tileContainer.removeChildAt( 0 ); }
			m_tileContainer = new Sprite();
			m_tileContainer.visible = false;
			m_stage.addChild( m_tileContainer );
			m_tileContainer.addEventListener( MouseEvent.CLICK, OnTilerClick );
		}
		
		public function Init():void {
			AddListeners();
			m_stage.addChild( m_tileContainer );
		}
		
		/** Undo the last step, for now any addChild steps */
		public function Undo():void {
			var length:int = m_undoSteps.length;
			if ( length > 0 ) {
				var step:Object = m_undoSteps[ length-1 ];
				//deleting a tile?
				if ( step[ "indexOf" ] && step.indexOf( "." ) ) {
					var classAndMethod:Array = step.split( "." );
					var object:* = classAndMethod[ 0 ];
					var args:String =  classAndMethod[1].replace( /.*\(([a-z0-9]+)\).*/g, "$1" );
					var method:String = classAndMethod[1].replace( /([a-zA-Z]+)\(.*/g, "$1" );
					
					args = args == "last" ? String(this[ object ].numChildren-1) : args;
					
					this[ object][ method ].apply( this, [args] );
				} 
				//undo a tile delete?
				else if ( step.hasOwnProperty( "target" ) ) {
					var obj:Object = m_undoSteps[ length-1 ];
					var tile:Sprite = CopySpriteTransformation( obj.args, obj.objectCopy );
					
					this[ obj.target ][ obj.method ].apply( this, [tile] );
					if ( tile is tileobject ) { tile.addEventListener( MouseEvent.CLICK, AdjustProperties ); }
					else { tile.addEventListener( MouseEvent.CLICK, AdjustSpawnProperties ); }
				}
				//calling a local method
				else {
					this[ step.method ].apply( this, step.args is Array ? step.args : [ step.args ] );
				}
				m_undoSteps.splice( length-1, 1 );
			}
		}
		
		/** Place the bitmap tile on the correct layer */
		private function PlaceTile( bitmap:Bitmap ):void {
			var bounds:Rectangle = m_tileContainer.getBounds( m_activeLayer );
			bounds.x = GetClosestValue( bounds.x, gridColumns );
			bounds.y = GetClosestValue( bounds.y, gridRows );
			
			var t:tileobject = new tileobject();
			t.addChild( bitmap );
			t.name = bitmap.name;
			//t.addEventListener( MouseEvent.CLICK, AdjustProperties );
			AddPropertiesListener(t);
			t.x = bounds.x;
			t.y = bounds.y;
			m_activeLayer.addChild( t );
			m_focusTile = t;
			
			//if you are holding shift, the tile will reappear at the cursor location
			if ( m_keys[ Keyboard.SHIFT ] ) { 
				UpdateActiveTile( bitmap ); 
			} else {
				ClearTileContainer();
			}
		}
		
		public function AddPropertiesListener( obj:*, func:String="AdjustProperties" ):void {
			if ( !(obj.hasEventListener( MouseEvent.CLICK ) ) ) {
				obj.addEventListener( MouseEvent.CLICK, this[ func ] );
			}
		}
		
		/** Place a spawner at the correct location */
		private function PlaceSpawner( spawn:spawner ):void {
			var bounds:Rectangle = m_tileContainer.getBounds( m_activeLayer );
			bounds.x = GetClosestValue( bounds.x, gridColumns );
			bounds.y = GetClosestValue( bounds.y, gridRows );
			
			spawn.addEventListener( MouseEvent.CLICK, AdjustSpawnProperties );
			spawn.x = bounds.x;
			spawn.y = bounds.y;
			spawners.addChild( spawn );
			m_focusTile = spawn;
			

			ClearTileContainer();
		}
		
		/** Place a spawner at the correct location */
		private function PlaceItem( item:items ):void {
			var bounds:Rectangle = m_tileContainer.getBounds( m_activeLayer );
			bounds.x = GetClosestValue( bounds.x, gridColumns );
			bounds.y = GetClosestValue( bounds.y, gridRows );
			
			item.addEventListener( MouseEvent.CLICK, AdjustItemProperties );
			item.x = bounds.x;
			item.y = bounds.y;
			spawners.addChild( item );
			m_focusTile = item;
			
			
			ClearTileContainer();
		}
		
		/** Delete tile */
		public function DeleteTile( e:Event=null ):void {
			var sprCopy:Sprite;
			if ( m_focusTile is tileobject ) {
				sprCopy = new Sprite();
				sprCopy.addChild( m_focusTile.getChildAt( 0 ) );
				cl_tileproperties.instance.HideMenu();
			} 
			else {
				sprCopy = m_focusTile;
				cl_spawnerproperties.instance.HideMenu();
			}
			m_undoSteps.push( { method: "addChild", target: m_focusTile.parent.name, args: sprCopy, objectCopy: CopyFocusTile() } );
			m_focusTile.parent.removeChild( m_focusTile );
		}
		
		/** Makes a copy of the current focus tile */
		private function CopyFocusTile():Object {
			var data:ByteArray = new ByteArray();
			data.writeObject( m_focusTile );
			data.position = 0;
			var obj:Object = data.readObject();
			return obj;
		}
		
		/** Makes the sprite have all the transformation properties of the copy object */
		private function CopySpriteTransformation( tile:Sprite, fields:Object ):Sprite {
			tile.x = fields.x;
			tile.y = fields.y;
			tile.rotation = fields.rotation;
			tile.scaleX = fields.scaleX;
			tile.scaleY = fields.scaleY;
			return tile;
		}
		
		/** Callback when tile properties are changed */
		public function ApplyTileProperties( e:Event ):void {
			//only transform tile objects
			if ( m_focusTile is tileobject ) {
				var prevW:Number = m_focusTile.width;
				var prevH:Number = m_focusTile.height;
				var prevScale:Point = new Point( m_focusTile.scaleX, m_focusTile.scaleY );
				m_focusTile.scaleX = cl_tileproperties.instance.scaleX;
				m_focusTile.scaleY = cl_tileproperties.instance.scaleY;
				
				//adjust position based on scaling to keep orientation
				if ( prevScale.x < 0 && m_focusTile.scaleX > 0 ) 		{ m_focusTile.x -= m_focusTile.width*Math.abs(prevScale.x); } 
				else if ( prevScale.x > 0 && m_focusTile.scaleX < 0 ) 	{ m_focusTile.x += m_focusTile.width; }
				else if ( prevScale.x < 0 && m_focusTile.scaleX < 0 ) 	{ m_focusTile.x += m_focusTile.width - prevW; }
				
				//adjust position based on scaling to keep orientation
				if ( prevScale.y < 0 && m_focusTile.scaleY > 0 ) 		{ m_focusTile.y -= m_focusTile.height*Math.abs(prevScale.y); } 
				else if ( prevScale.y > 0 && m_focusTile.scaleY < 0 ) 	{ m_focusTile.y += m_focusTile.height; }
				else if ( prevScale.y < 0 && m_focusTile.scaleY < 0 ) 	{ m_focusTile.y += m_focusTile.height - prevH; }
				
				//rotate the bitmap only
				var matrix:Matrix = new Matrix();
				matrix.translate( -m_focusTile.width/2, -m_focusTile.height/2 );
				matrix.rotate( cl_tileproperties.instance.rotation * Math.PI / 180 );
				matrix.translate( m_focusTile.width/2, m_focusTile.height/2 );
				m_focusTile.getChildAt(0).transform.matrix = matrix;
			
			
				var bounds:Rectangle = m_focusTile.getBounds( m_stage );
				cl_tileproperties.instance.SetPosition( new Point( bounds.x + bounds.width, bounds.y ) );
			}
			m_focusTile.type = cl_tileproperties.instance.type.search(/default|wall|floor/g) != -1 ? cl_tileproperties.instance.type.match(/default|wall|floor/g)[0] : "default";
		}
		
		/** Callback when tile properties are changed */
		public function ApplySpawnerProperties( e:Event ):void {
			if ( m_focusTile is spawner ) {
				var bounds:Rectangle = m_focusTile.getBounds( m_stage );
				cl_spawnerproperties.instance.SetPosition( new Point( bounds.x + bounds.width, bounds.y ) );
				
				m_focusTile.enemiesPerMinute 	= cl_spawnerproperties.instance.enemiesPerMinute;
				m_focusTile.enemyTypes 			= cl_spawnerproperties.instance.enemyTypes;
				m_focusTile.spawnDirection 		= cl_spawnerproperties.instance.spawnDirection;
				m_focusTile.isPlayerSpawn 		= cl_spawnerproperties.instance.isPlayerSpawn;
			}
		}
		
		/** Callback when tile properties are changed */
		public function ApplyItemProperties( e:Event ):void {
			if ( m_focusTile is items ) {
				var bounds:Rectangle = m_focusTile.getBounds( m_stage );
				cl_itemproperties.instance.SetPosition( new Point( bounds.x + bounds.width, bounds.y ) );
				
				m_focusTile.type = cl_itemproperties.instance.type;
			}
		}
		
		/** Change the focus tile to the selected one */
		private function AdjustProperties( e:MouseEvent ):void {
			m_focusTile = e.target as Sprite;
			var bounds:Rectangle = m_focusTile.getBounds( m_stage );
			cl_tileproperties.instance.SetPosition( new Point( bounds.x + width + 150 > 960 ? bounds.x - 150 : bounds.x + bounds.width, bounds.y + 300  > 800 ? bounds.y - 300 : bounds.y  ) );
			cl_tileproperties.instance.ShowMenu();
		}
		
		/** Change the focus tile to the selected one */
		private function AdjustSpawnProperties( e:MouseEvent ):void {
			m_focusTile = e.target as Sprite;
			var bounds:Rectangle = m_focusTile.getBounds( m_stage );
			cl_spawnerproperties.instance.SetPosition( new Point( bounds.x + width + 150 > 960 ? bounds.x - 150 : bounds.x + bounds.width, bounds.y + 300  > 800 ? bounds.y - 300 : bounds.y ) );
			cl_spawnerproperties.instance.ShowMenu();
		}
		
		/** Change the focus tile to the selected one */
		private function AdjustItemProperties( e:MouseEvent ):void {
			m_focusTile = e.target as Sprite;
			var bounds:Rectangle = m_focusTile.getBounds( m_stage );
			cl_itemproperties.instance.SetPosition( new Point( bounds.x + width + 150 > 960 ? bounds.x - 150 : bounds.x + bounds.width, bounds.y + 300  > 800 ? bounds.y - 300 : bounds.y ) );
			cl_itemproperties.instance.ShowMenu();
		}
		
		/** Find the closest position to the list of positions
		 * @param position - passed position to find the closest value to
		 * @param list - list of axis positions
		 * @param edging - when getting the closest value, if this i set to true the edges of the level are included in the calculation
		 * */
		private function GetClosestValue( position:Number, list:*, edging:Boolean=false ):Number {
			var pos:Number = position;
			var currentDistance:Number = int.MAX_VALUE;
			
			var i:int;
			var dist:Number = 0;
			var length:int = list.length - (edging ? 0 : 1);
			for ( ; i < length; ++i ) {
				dist = Math.abs( list[i] - position );
				if ( dist <= currentDistance ) { currentDistance = dist; pos = list[i]; }
			}
			return pos;
		}
		
		/** Remove a collision box */
		private function RemoveCollision( layer:Sprite, name:String="last" ):void {
			var i:int;
			for ( ; i < layer.numChildren; ++i ) {
				if ( layer.getChildAt( i ) is collisionobject ) {
					if ( name == "last" || layer.getChildAt( i ).name == name ) {
						layer.removeChildAt(i);
						return;
					}
				}
			}
		}
		
		/*========================================================================================
		EVENT HANDLING
		========================================================================================*/
		private function AddListeners():void {
			m_stage.addEventListener( MouseEvent.MOUSE_MOVE, 		UpdateTiler );
			m_stage.addEventListener( MouseEvent.MOUSE_DOWN, 		OnMouseDown );
			m_stage.addEventListener( MouseEvent.MOUSE_UP, 			OnMouseUp );
			m_stage.addEventListener( KeyboardEvent.KEY_DOWN, 		OnKeyDown );
			m_stage.addEventListener( KeyboardEvent.KEY_UP, 		OnKeyUp );
		}
		
		private function RemoveListeners():void {
			m_stage.removeEventListener( MouseEvent.MOUSE_MOVE, 	UpdateTiler );
			m_stage.removeEventListener( MouseEvent.MOUSE_DOWN, 	OnMouseDown );
			m_stage.removeEventListener( MouseEvent.MOUSE_UP, 		OnMouseUp );
			m_stage.removeEventListener( KeyboardEvent.KEY_DOWN, 	OnKeyDown );
			m_stage.removeEventListener( KeyboardEvent.KEY_UP, 		OnKeyUp );
		}
		
		
		private function OnKeyDown( e:KeyboardEvent ):void {
			if ( !m_keys[ e.keyCode ] ) {
				m_keys[ e.keyCode ] = e.keyCode;
			}
			CheckForKeyEvents();
		}
		
		private function OnKeyUp( e:KeyboardEvent ):void {
			if ( m_keys[ e.keyCode ] ) {
				m_keys[ e.keyCode ] = null;
			}
			if ( e.keyCode == Keyboard.SPACE ) {
				m_origin = null;
			}
			if ( e.keyCode == Keyboard.ESCAPE ) {
				ClearTileContainer();
			}
		}
		
		/** Update the tile container position so it is centered on the mouse */
		private function UpdateTiler( e:MouseEvent=null ):void {
			//only change the visiblity of mouse state is not down, 
			//if the mouse state is down we are probably drawing collisions
			if ( m_mouseState != DOWN ) {
				//if ( m_tileContainer && m_stage && m_stage.mouseY <= m_stage.stageHeight - 100) {
					m_tileContainer.x = m_stage.mouseX - m_tileContainer.width / 2;
					m_tileContainer.y = m_stage.mouseY - m_tileContainer.height / 2;
					m_tileContainer.visible = true;
				//} 
				//else {
					//m_tileContainer.visible = false;
				//}
			}
			else if ( m_activeCollisionBox ) {
				UpdateCollision();
			}
			
			if ( e && m_keys[ Keyboard.SPACE ] && e.buttonDown ) {
				var distX:Number = m_stage.mouseX - m_origin.x;
				var distY:Number = m_stage.mouseY - m_origin.y;
				
				grid.x += distX;
				grid.y += distY;
			}
			m_origin = new Point( m_stage.mouseX, m_stage.mouseY );
		}
		
		/** Check for hot keys like CTRL+Z for undo, or SHIFT for increased movement of the focus tile */
		private function CheckForKeyEvents():void {
			if ( m_keys[ Keyboard.CONTROL ] && m_keys[ Keyboard.Z ] ) {
				Undo();
			}
			else if ( !m_keys[ Keyboard.CONTROL ] ) {
				var move:int = snapToGrid ? unitSize : 1;
				move *= m_keys[ Keyboard.SHIFT ] ? 10 : 1;
				
				//only manipulate if there is a focused tile
				if ( m_focusTile ) {
					if ( m_keys[ Keyboard.LEFT ] ) {
						m_focusTile.x -= move;
					}
					else if ( m_keys[ Keyboard.RIGHT ] ) {
						m_focusTile.x += move;
					}
					else if ( m_keys[ Keyboard.UP ] ) {
						m_focusTile.y -= move;
					}
					else if ( m_keys[ Keyboard.DOWN ] ) {
						m_focusTile.y += move;
					}
				}
				if ( m_keys[ Keyboard.SPACE ] && !m_origin ) {
					m_origin = new Point( m_stage.mouseX, m_stage.mouseY );
				}
			}
			//draw collisions
			else if ( m_mouseState == DOWN && !m_activeCollisionBox ) {
				m_tileContainer.visible = false;
				var origin:Point = new Point( GetClosestValue( m_activeLayer.mouseX, gridColumns ), GetClosestValue( m_activeLayer.mouseY, gridRows ) );
				var collisionBox:collisionobject = new collisionobject();
				collisionBox.graphics.beginFill( 0x00FF00, 0.75 );
				collisionBox.graphics.drawRect( 0, 0, 1, 1 );
				collisionBox.graphics.endFill();
				collisionBox.x = origin.x;
				collisionBox.y = origin.y;
				collisions.addChild( collisionBox );
				//newCollision.name = "collisionBox_" + _collisionMap.length;
				m_activeCollisionBox = collisionBox;
			}
		}
		
		/** Called during mouse move when drawing a collision. Updates the sizing of the collision box */
		private function UpdateCollision():void {
			var nextPoint:Point = new Point( GetClosestValue( m_activeLayer.mouseX, gridColumns, true ), GetClosestValue( m_activeLayer.mouseY, gridRows, true ) );
			if ( nextPoint.x == m_activeCollisionBox.x && nextPoint.y == m_activeCollisionBox.y ) { return; }
			
			m_activeCollisionBox.graphics.clear();
			m_activeCollisionBox.graphics.beginFill( 0x00FF00, 0.5 );
			m_activeCollisionBox.graphics.drawRect( 0,0, nextPoint.x - m_activeCollisionBox.x, nextPoint.y - m_activeCollisionBox.y );
			m_activeCollisionBox.graphics.endFill();
		}
		
		private function OnCollisionDone():void {
			m_undoSteps.push( { method: "RemoveCollision", args: [m_activeLayer,"last"] } );
		}
		
		/** this is really only used for drawing collisin boxes */
		private function OnMouseDown( e:MouseEvent ):void {
			m_mouseState = DOWN;
			CheckForKeyEvents();
		}
		
		/** this is really only used for ending draw of collisin boxes */
		private function OnMouseUp( e:MouseEvent ):void {
			m_mouseState = UP;
			m_tileContainer.visible = true;
			UpdateTiler();
			if ( m_activeCollisionBox ) {
				m_activeCollisionBox.addEventListener( MouseEvent.CLICK, AdjustProperties );
				OnCollisionDone();
				m_activeCollisionBox = null;
			}
		}
		
		/** When we select a place on the editor, place the bitmap at that location rounded */
		private function OnTilerClick( e:MouseEvent ):void {
			if ( m_focusTile is tileobject || !m_focusTile && m_currentBitmap ) {
				m_tileContainer.scaleX = m_tileContainer.scaleY = 1;
				var bmd:BitmapData = new BitmapData( m_tileContainer.width, m_tileContainer.height, true, 0 );
				bmd.draw( m_currentBitmap );
				
				var bitmap:Bitmap = new Bitmap( bmd );
				bitmap.name = m_currentBitmap.name;
				PlaceTile( bitmap );
			} 
			else if ( e.target is spawner ) {
				m_tileContainer.scaleX = m_tileContainer.scaleY = 1;
				var spawn:spawner = m_tileContainer.getChildAt(0) as spawner;
				PlaceSpawner( spawn );
			}
			else if ( e.target is items ) {
				m_tileContainer.scaleX = m_tileContainer.scaleY = 1;
				var item:items = m_tileContainer.getChildAt(0) as items;
				PlaceItem( item );
			}
			
			m_undoSteps.push( m_activeLayer.name+".removeChildAt(last)" );
		}
		
		/*========================================================================================
		ANCILLARY
		========================================================================================*/
		/** Set the active layer for tiles to be placed on to 
		 * @param layer - 0 for background, 1 for midground, 2 for foreground
		 * */
		public function SetActiveLayer( layer:int ):void {
			switch( layer ) {
				case 1:
					m_activeLayer = midground;
					break;
				case 2:
					m_activeLayer = foreground;
					break;
				default:
					m_activeLayer = background;
					break;
			}
		}
		
		public function get snapToGrid():Boolean { return m_snapToGrid; }
		public function set snapToGrid(val:Boolean):void { 
			m_snapToGrid = val; 
			if ( m_focusTile ) {
				m_focusTile.x = this.GetClosestValue( m_focusTile.x, gridColumns );
				m_focusTile.y = this.GetClosestValue( m_focusTile.y, gridRows );
			}
		}
		
		static public function set stage( s:Stage ):void { m_stage = s; }
		static public function get stage():Stage { return m_stage; }
		
		static public function get instance():r_tiler { return sm_instance = sm_instance ? sm_instance : new r_tiler( new privateclass() ); }
	}
}

class privateclass{}