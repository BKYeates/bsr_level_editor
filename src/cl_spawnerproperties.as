package
{
	import com.bit101.components.CheckBox;
	import com.bit101.components.InputText;
	import com.bit101.components.Label;
	import com.bit101.components.Panel;
	import com.bit101.components.PushButton;
	import com.bit101.components.RadioButton;
	
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	
	public class cl_spawnerproperties
	{
		private var m_propertyPanel:Panel;
		
		private var m_enemiesPerMinute:InputText;
		private var m_enemyTypes:InputText;
		private var m_spawnDirection:InputText;
		private var m_rotationInput:InputText;
		private var m_settingsLayer:Sprite;
		private var m_stage:Stage;
		private var m_applyCallback:Function;
		private var m_deleteCallback:Function;
		private var m_tiletype:InputText;
		private var m_isPlayerSpawn:CheckBox;
		
		static private var sm_instance:cl_spawnerproperties;
		
		public function cl_spawnerproperties( settingsLayer:Sprite, stage:Stage, applyCallback:Function, deleteCallback:Function )
		{
			if ( sm_instance ) { throw new Error( "cl_spawnerproperties already exists, use cl_spawnerproperties.instance" ); }
			m_stage 		= stage;
			sm_instance 	= this;
			m_settingsLayer = settingsLayer;
			m_applyCallback = applyCallback;
			m_deleteCallback = deleteCallback;
			
			Init();
		}
		
		private function Init():void {
			m_propertyPanel = new Panel( m_settingsLayer, 0, 0 );
			m_propertyPanel.setSize( 150, 250 );
			m_propertyPanel.filters = [new DropShadowFilter(10,45,0,0.7,10,10)];
			
			m_isPlayerSpawn  = new CheckBox( m_propertyPanel, m_propertyPanel.width/2 - 50, 5, "Spawn Player" );
			
			//input
			m_enemiesPerMinute = new InputText( m_propertyPanel, m_propertyPanel.width/2 - 50, m_isPlayerSpawn.y + m_isPlayerSpawn.height + 25 );
			m_enemiesPerMinute.text = "0";
			m_enemiesPerMinute.setSize( 100, 25 );
			
			var enemiesPerMinuteLabel:Label = new Label( m_propertyPanel, m_enemiesPerMinute.x + m_enemiesPerMinute.width/2, m_enemiesPerMinute.y, "Enemies/minute" );
			enemiesPerMinuteLabel.y -= enemiesPerMinuteLabel.height;
			enemiesPerMinuteLabel.x -= enemiesPerMinuteLabel.width/2;
			
			//type input
			m_enemyTypes = new InputText( m_propertyPanel, m_propertyPanel.width/2 - 50, m_enemiesPerMinute.y + m_enemiesPerMinute.height + enemiesPerMinuteLabel.height );
			m_enemyTypes.text = "random|fast|flying";
			m_enemyTypes.setSize( 100, 25 );
			
			var m_enemyTypesLabel:Label = new Label( m_propertyPanel, m_enemyTypes.x + m_enemyTypes.width/2, m_enemyTypes.y, "Enemy types:" );
			m_enemyTypesLabel.y -= m_enemyTypesLabel.height;
			m_enemyTypesLabel.x -= m_enemyTypesLabel.width/2;
			
			//type input
			m_spawnDirection = new InputText( m_propertyPanel, m_propertyPanel.width/2 - 50, m_enemyTypes.y + m_enemyTypes.height + m_enemyTypesLabel.height );
			m_spawnDirection.text = "right";
			m_spawnDirection.setSize( 100, 25 );
			
			var m_spawnDirectionLabel:Label = new Label( m_propertyPanel, m_spawnDirection.x + m_spawnDirection.width/2, m_spawnDirection.y, "Spawn Direction:" );
			m_spawnDirectionLabel.y -= m_spawnDirectionLabel.height;
			m_spawnDirectionLabel.x -= m_spawnDirectionLabel.width/2;
			
			//apply new settings
			var apply:PushButton = new PushButton( m_propertyPanel, m_propertyPanel.width/2, m_propertyPanel.height - (22 * 3), "[Apply Changes]", m_applyCallback );
			apply.x -= apply.width/2;
			
			//apply new settings
			var del:PushButton = new PushButton( m_propertyPanel, m_propertyPanel.width/2, m_propertyPanel.height - (22 * 2), "[Delete Spawner]", m_deleteCallback );
			del.x -= del.width/2;
			m_propertyPanel.visible = false;
			
			//apply new settings
			var close:PushButton = new PushButton( m_propertyPanel, m_propertyPanel.width/2, m_propertyPanel.height - 22, "[Close]", HideMenu );
			close.x -= close.width/2;
			m_propertyPanel.visible = false;
		}
		
		public function SetPosition( position:Point ):void {
			m_propertyPanel.x = position.x;
			m_propertyPanel.y = position.y;
		}
		
		public function ShowMenu():void { m_propertyPanel.visible = true; }
		public function HideMenu(e:Event=null):void { m_propertyPanel.visible = false; }
		
		public function get enemiesPerMinute():Number 	{ return Number(m_enemiesPerMinute.text); }
		public function get spawnDirection():String 	{ return m_spawnDirection.text; }
		public function get enemyTypes():Array 			{ return m_enemyTypes.text.split("|"); }
		public function get isPlayerSpawn():Boolean 	{ return m_isPlayerSpawn.selected; }
		
		static public function get instance():cl_spawnerproperties { return sm_instance; }
	}
}