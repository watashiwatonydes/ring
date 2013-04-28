package interaction
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Joints.b2MouseJoint;
	import Box2D.Dynamics.Joints.b2MouseJointDef;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2Fixture;
	
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import physics.JointConnection;
	import physics.VertexBody;

	public class MousePicking extends EventDispatcher
	{
		private var _target:Sprite;
		private var _bodies:Vector.<VertexBody>;

		private var _pickingAnchor:VertexBody;
		private var _pickingJoints:Vector.<JointConnection> = new Vector.<JointConnection>();
		private var _mouseJoint:b2MouseJoint;
		private var _dragJointConnection:JointConnection;
		
		public function MousePicking( target:Sprite, bodies:Vector.<VertexBody> )
		{
			if ( !target.stage )
				throw new Error( "MousePicking requires the target: " + target.name + " to be added to the stage beforehand." );
			
			_target = target;
			_bodies = bodies;
		}
	
		protected function mouseToWorld():b2Vec2
		{
			var buffer:b2Vec2 = new b2Vec2( _target.stage.mouseX / Config.WORLDSCALE, _target.stage.mouseY / Config.WORLDSCALE );
			return buffer;
		}
		
		public function update():void
		{
			var mousePoint:Point 			= new Point( _target.stage.mouseX, _target.stage.mouseY );
			
			var someVertexBody:VertexBody 	= null;
			var dist:Number 				= Number.MAX_VALUE;
			var toGlobalPoint:Point;
			
			for each(var b:VertexBody in _bodies)
			{
				var dist2Point:Number 	= Point.distance( b.pixelCoordinates, mousePoint );
				if( dist2Point < dist )
				{
					someVertexBody 	= b;
					dist 			= dist2Point;
				}
			}

			if ( dist < 80 )
			{
				
				if ( _pickingAnchor != null && _dragJointConnection != null )
				{
					// trace ( "bodyA: ", _dragJointConnection.joint.GetBodyA() == someVertexBody.body )
					// trace ( "bodyB: ", _dragJointConnection.joint.GetBodyB() == someVertexBody.body )
					
					if ( _dragJointConnection.joint.GetBodyB() != someVertexBody.body ) // Another vertex is closer than the current one
					{
						handleMouseUp( null ); // Kill the current joint 
						
						createPickingVertexAndJoint( mousePoint, someVertexBody ); // Creates a new one	
					}
					else
					{
						handleMouseMove( null );
					}
				}
				else
				{
					createPickingVertexAndJoint( mousePoint, someVertexBody );						
				}
			}
			else
			{
				handleMouseMove( null );
			}
			
			if ( dist >= 150 ) // Kill all joints
			{
				handleMouseUp( null );	
			}
		}
		
		private function createPickingVertexAndJoint( mousePoint:Point, vertex:VertexBody ):void
		{
			_pickingAnchor 					= new VertexBody( mousePoint, b2Body.b2_dynamicBody );
			
			_pickingAnchor.graphics.clear();
			_pickingAnchor.graphics.lineStyle( 1, 0xff0000 );
			_pickingAnchor.graphics.beginFill( 0xff0000, .4 );
			_pickingAnchor.graphics.drawCircle(0, 0, 20);
			_pickingAnchor.graphics.endFill();
			
			_pickingAnchor.x 				= mousePoint.x * Config.WORLDSCALE;
			_pickingAnchor.y 				= mousePoint.y * Config.WORLDSCALE;
			
			_target.stage.addChild( _pickingAnchor );
			
			_dragJointConnection = new JointConnection( JointConnection.ROPE_JOINT, _pickingAnchor, vertex );
			_target.stage.addChild( _dragJointConnection );
			_dragJointConnection.draw();
			
			var v2:b2Vec2 = mouseToWorld();
			Config.WORLD.QueryPoint( this.queryCallback, v2 );
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
					jointDef.maxForce	    = 1000 * touchedBody.GetMass();
					jointDef.frequencyHz    = 6;
					jointDef.dampingRatio   = .1;
					
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
			for each ( var j:JointConnection in _pickingJoints )
			{
				Config.WORLD.DestroyJoint( j.joint );
				j.joint = null;
				j = null;
			}
			
			_pickingJoints.length = 0;
			
			if( _dragJointConnection )
			{
				_target.stage.removeChild( _dragJointConnection );
				Config.WORLD.DestroyJoint( _dragJointConnection.joint );
				_dragJointConnection.joint 	= null;
				_dragJointConnection 		= null;
			}
			
			if( _pickingAnchor )
			{
				if ( _target.stage.contains( _pickingAnchor ) )
					_target.stage.removeChild( _pickingAnchor );
				
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
			// if( event.buttonDown )
			{
				if( _mouseJoint ){
					
					mousePos = mouseToWorld();
					_mouseJoint.SetTarget( mousePos );
					
					
					var anchorA:b2Vec2 = _mouseJoint.GetAnchorA();
					var anchorB:b2Vec2 = _mouseJoint.GetAnchorB();
					
					var diffX:Number = anchorA.x - anchorB.x;
					var diffY:Number = anchorA.y - anchorB.y;
					
					var e:PickingEvent = new PickingEvent( PickingEvent.PICKING_UPDATE );
					e.x = diffX;
					e.y = diffY;
					dispatchEvent( e );
				}
				
				if ( _pickingAnchor )
				{
					_pickingAnchor.x = mousePos.x * Config.WORLDSCALE;
					_pickingAnchor.y = mousePos.y * Config.WORLDSCALE;
					
					_pickingAnchor.alpha 	+= ( 0 - _pickingAnchor.alpha ) * 0.05;
					_pickingAnchor.scaleX	+= ( 0 - _pickingAnchor.scaleX ) * 0.05;
					_pickingAnchor.scaleY	+= ( 0 - _pickingAnchor.scaleY ) * 0.05;
				}
			}
		}
		
		public function draw():void 
		{
			if( _pickingAnchor )
			{
				_pickingAnchor.update();
				_pickingAnchor.draw();
			}
		}
		
	}
}