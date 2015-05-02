package
{
	import com.bit101.components.CheckBox;
	import com.bit101.components.InputText;
	import com.bit101.components.Label;
	import com.bit101.components.Panel;
	import com.bit101.components.PushButton;
	
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;

	/** cl_itempropteries */
	public class cl_itemproperties {
		/*===============
		PRIVATE
		===============*/
		private var m_settingsLayer:Sprite;
		private var m_stage:Stage;
		private var m_applyCallback:Function;
		private var m_deleteCallback:Function;
		private var m_propertyPanel:Panel;
		private var m_typeInput:InputText;
		
		/*===============
		PROTECTED
		===============*/
		static protected var sm_instance:cl_itemproperties;
		
		/*===============
		PUBLIC
		===============*/
		
		/*===============
		CONSTANTS
		===============*/
		
		public function cl_itemproperties( settingsLayer:Sprite, stage:Stage, applyCallback:Function, deleteCallback:Function )
		{
			if ( sm_instance ) { throw new Error( "cl_itemproperties already exists, use the instance getter" ); }
			sm_instance = this;
			
			m_stage 		= stage;
			sm_instance 	= this;
			m_settingsLayer = settingsLayer;
			m_applyCallback = applyCallback;
			m_deleteCallback = deleteCallback;
			
			Init();
		}
		
		private function Init():void {
			m_propertyPanel = new Panel( m_settingsLayer, 0, 0 );
			m_propertyPanel.setSize( 150, 150 );
			m_propertyPanel.filters = [new DropShadowFilter(10,45,0,0.7,10,10)];
			
			//input
			m_typeInput = new InputText( m_propertyPanel, m_propertyPanel.width/2 - 50, 25 );
			m_typeInput.text = "0";
			m_typeInput.setSize( 100, 25 );
			
			var typeLabel:Label = new Label( m_propertyPanel, m_typeInput.x + m_typeInput.width/2, m_typeInput.y, "Set a type" );
			typeLabel.y -= typeLabel.height;
			typeLabel.x -= typeLabel.width/2;
			
			m_propertyPanel.visible = false;
			
			//apply new settings
			var apply:PushButton = new PushButton( m_propertyPanel, m_propertyPanel.width/2, m_propertyPanel.height - (22 * 3), "[Apply Changes]", m_applyCallback );
			apply.x -= apply.width/2;
			
			//apply new settings
			var del:PushButton = new PushButton( m_propertyPanel, m_propertyPanel.width/2, m_propertyPanel.height - (22 * 2), "[Delete Item]", m_deleteCallback );
			del.x -= del.width/2;
			m_propertyPanel.visible = false;
			
			//apply new settings
			var close:PushButton = new PushButton( m_propertyPanel, m_propertyPanel.width/2, m_propertyPanel.height - 22, "[Close]", HideMenu );
			close.x -= close.width/2;
			m_propertyPanel.visible = false;
		}
		
		/*========================================================================================
		ANCILLARY
		========================================================================================*/
		static public function get instance():cl_itemproperties { return sm_instance; }
		
		public function get type():String { return m_typeInput.text; }
		
		public function SetPosition( position:Point ):void {
			m_propertyPanel.x = position.x;
			m_propertyPanel.y = position.y;
		}
		
		public function ShowMenu():void { m_propertyPanel.visible = true; }
		public function HideMenu(e:Event=null):void { m_propertyPanel.visible = false; }
	}
}