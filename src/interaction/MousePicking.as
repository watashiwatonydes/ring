package interaction
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Joints.b2MouseJoint;
	import Box2D.Dynamics.Joints.b2MouseJointDef;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2Fixture;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import physics.JointConnection;
	import physics.VertexBody;

	public class MousePicking
	{
		private var _body:VertexBody;

		private var _pickingAnchor:VertexBody;
		private var _pickingJoints:Vector.<JointConnection> = new Vector.<JointConnection>();
		private var _mouseJoint:b2MouseJoint;
		private var _dragJointConnection:JointConnection;
		
		public function MousePicking( body:VertexBody )
		{
			if ( !body.stage )
				throw new Error( "MousePicking requires the target: " + body.name + " to be added to the stage beforehand." );
			
			_body = body;
			
			createPicker();
		}
	
		protected function mouseToWorld():b2Vec2
		{
			var buffer:b2Vec2 = new b2Vec2( _body.stage.mouseX / Config.WORLDSCALE, _body.stage.mouseY / Config.WORLDSCALE );
			return buffer;
		}
		
		protected function createPicker():void
		{
			var v2:b2Vec2 = mouseToWorld();
			Config.WORLD.QueryPoint( this.queryCallback, v2 );
			
			_body.stage.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
			_body.stage.addEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
		}
		
		private function queryCallback( fixture:b2Fixture ):void
		{
			if (fixture)
			{
				var touchedBody:b2Body         = fixture.GetBody();
				if( touchedBody.GetType() == b2Body.b2_dynamicBody )
				{
					var jointDef:b2MouseJointDef = new b2MouseJointDef();
					
					jointDef.bodyA 		    = Config.WORLD.GetGroundBody();
					jointDef.bodyB 		    = touchedBody;
					jointDef.target 	    = mouseToWorld();
					jointDef.maxForce	    = 2000 * touchedBody.GetMass();
					jointDef.frequencyHz    = 2;
					jointDef.dampingRatio   = 0;
					
					_mouseJoint				= Config.WORLD.CreateJoint( jointDef ) as b2MouseJoint;
					
					var mousePos:b2Vec2 = null;
					if( _mouseJoint )
					{
						mousePos = mouseToWorld();
						_mouseJoint.SetTarget( mousePos );
					}
				}
			}
		}
		
		protected function handleMouseUp(event:MouseEvent):void
		{
			_body.stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
			_body.stage.removeEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
			
			for each ( var j:JointConnection in _pickingJoints )
			{
				Config.WORLD.DestroyJoint( j.joint );
				j.joint = null;
				j = null;
			}
			
			_pickingJoints.length = 0;
			
			if( _dragJointConnection )
			{
				_body.stage.removeChild( _dragJointConnection );
				Config.WORLD.DestroyJoint( _dragJointConnection.joint );
				_dragJointConnection.joint 	= null;
				_dragJointConnection 		= null;
			}
			
			if( _pickingAnchor )
			{
				if ( _body.stage.contains( _pickingAnchor ) )
					_body.stage.removeChild( _pickingAnchor );
				
				Config.WORLD.DestroyBody(_pickingAnchor.body);
				
				_pickingAnchor.body	= null;
				_pickingAnchor = null;
			}
			
			if(_mouseJoint)
			{
				Config.WORLD.DestroyJoint( _mouseJoint );
				_mouseJoint = null;
			}
		}
		
		protected function handleMouseMove(event:MouseEvent):void
		{
			
			var mousePos:b2Vec2 = null;
			if( _mouseJoint ){
				
				mousePos = mouseToWorld();
				_mouseJoint.SetTarget( mousePos );
			}
		}
		
		public function draw():void 
		{
			if( _pickingAnchor )
			{
				_pickingAnchor.update();
				_dragJointConnection.draw();
			}
		}
		
	}
}