package
{
	import com.bit101.components.InputText;
	import com.bit101.components.Label;
	import com.bit101.components.Panel;
	import com.bit101.components.PushButton;
	
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;

	public class cl_tileproperties
	{
		
		private var m_propertyPanel:Panel;

		private var m_scaleXInput:InputText;
		private var m_scaleYInput:InputText;
		private var m_rotationInput:InputText;
		private var m_settingsLayer:Sprite;
		private var m_stage:Stage;
		private var m_applyCallback:Function;
		private var m_deleteCallback:Function;
		private var m_tiletype:InputText;
		
		static private var sm_instance:cl_tileproperties;

		
		public function cl_tileproperties( settingsLayer:Sprite, stage:Stage, applyCallback:Function, deleteCallback:Function )
		{
			if ( sm_instance ) { throw new Error( "cl_tileproperties already exists, use cl_tileproperties.instance" ); }
			m_stage 		= stage;
			sm_instance 	= this;
			m_settingsLayer = settingsLayer;
			m_applyCallback = applyCallback;
			m_deleteCallback = deleteCallback;
			
			Init();
		}
		
		private function Init():void {
			m_propertyPanel = new Panel( m_settingsLayer, 0, 0 );
			m_propertyPanel.setSize( 150, 300 );
			m_propertyPanel.filters = [new DropShadowFilter(10,45,0,0.7,10,10)];
			
			//scale X setting
			m_scaleXInput = new InputText( m_propertyPanel, m_propertyPanel.width/2 - 50, 25 );
			m_scaleXInput.text = "1";
			m_scaleXInput.setSize( 100, 25 );
			
			var scaleXLabel:Label = new Label( m_propertyPanel, m_scaleXInput.x + m_scaleXInput.width/2, m_scaleXInput.y, "Scale X:" );
			scaleXLabel.y -= scaleXLabel.height;
			scaleXLabel.x -= scaleXLabel.width/2;
			
			//scale Y setting
			m_scaleYInput = new InputText( m_propertyPanel, m_propertyPanel.width/2 - 50, m_scaleXInput.y + m_scaleXInput.height + scaleXLabel.height );
			m_scaleYInput.text = "1";
			m_scaleYInput.setSize( 100, 25 );
			
			var scaleYLabel:Label = new Label( m_propertyPanel, m_scaleYInput.x + m_scaleYInput.width/2, m_scaleYInput.y, "Scale Y:" );
			scaleYLabel.y -= scaleYLabel.height;
			scaleYLabel.x -= scaleYLabel.width/2;
			
			//rotation
			m_rotationInput = new InputText( m_propertyPanel, m_propertyPanel.width/2 - 50, m_scaleYInput.y + m_scaleYInput.height + scaleYLabel.height );
			m_rotationInput.text = "0";
			m_rotationInput.setSize( 100, 25 );
			
			var rotationLabel:Label = new Label( m_propertyPanel, m_rotationInput.x + m_rotationInput.width/2, m_rotationInput.y, "Rotation:" );
			rotationLabel.y -= rotationLabel.height;
			rotationLabel.x -= rotationLabel.width/2;
			
			//tile type input
			m_tiletype = new InputText( m_propertyPanel, m_propertyPanel.width/2 - 50, m_rotationInput.y + m_rotationInput.height + rotationLabel.height );
			m_tiletype.text = "default | wall | floor";
			m_tiletype.setSize( 100, 25 );
			
			var tiletypeLabel:Label = new Label( m_propertyPanel, m_scaleYInput.x + m_scaleYInput.width/2, m_tiletype.y, "Tile Type:" );
			tiletypeLabel.y -= tiletypeLabel.height;
			tiletypeLabel.x -= tiletypeLabel.width/2;
			
			//apply new settings
			var apply:PushButton = new PushButton( m_propertyPanel, m_propertyPanel.width/2, m_propertyPanel.height - (22 * 3), "[Apply Changes]", m_applyCallback );
			apply.x -= apply.width/2;
			
			//apply new settings
			var del:PushButton = new PushButton( m_propertyPanel, m_propertyPanel.width/2, m_propertyPanel.height - (22 * 2), "[Delete Tile]", m_deleteCallback );
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
		
		public function get scaleX():Number 	{ return Number(m_scaleXInput.text); }
		public function get scaleY():Number 	{ return Number(m_scaleYInput.text); }
		public function get rotation():Number 	{ return Number(m_rotationInput.text); }
		public function get type():String 		{ return m_tiletype.text; }
		
		static public function get instance():cl_tileproperties { return sm_instance; }
	}
}