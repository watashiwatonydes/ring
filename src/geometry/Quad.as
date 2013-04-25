package geometry
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	
	import interaction.MouseDestination;
	import interaction.MousePicking;
	
	import physics.JointConnection;
	import physics.PhysicHelper;
	import physics.VertexBody;
	
	public class Quad extends Sprite
	{
		private var _bodies:Vector.<VertexBody>;

		private var _bodiesConnections:Vector.<JointConnection>;
		private var _color:Number 				= 0xffffff;
		private var _alpha:Number				= .3;
		private var _creationComplete:Boolean	= false;
		private var FADE_FRICTION:Number		= Math.random() * .2;
		
		public function Quad( points:Vector.<Point>, bodyType:uint = 2 /* b2Body.b2_dynamicBody */ )
		{
			_bodies 	= new Vector.<VertexBody>(5, true);
			
			_bodies[0] 	= new VertexBody( points[0], bodyType );
			_bodies[1] 	= new VertexBody( points[1], bodyType );
			_bodies[2] 	= new VertexBody( points[2], bodyType );
			_bodies[3]	= new VertexBody( points[3], bodyType );
			
			var center:Point = Point.interpolate( points[0], points[3], .5 );
			_bodies[4]	= new VertexBody( center, bodyType );
			
			_bodiesConnections	= PhysicHelper.ConnectBodies( _bodies );
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		public function destroy():void
		{
			var b:VertexBody;
			var j:JointConnection;

			for each ( j in _bodiesConnections )
			{
				j.destroy();
				j = null;
			}
			
			for each ( b in _bodies )
			{
				b.destroy();
				b = null;
			}
			
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		protected function onAddedToStage(event:Event):void
		{
			
			var j:JointConnection;
			for each ( j in _bodiesConnections )
			{
				stage.addChild(j);
			}
			
			var r:VertexBody;
			for each ( r in _bodies )
			{
				stage.addChild( r );				
			}
			
			draw();
		}		
		
		public function draw():void
		{
			graphics.clear();

			var r:VertexBody
			for each ( r in _bodies )
			{
				r.update();
				r.draw();
			}
			
			graphics.lineStyle( 1, _color, _alpha );
			graphics.beginFill( _color, _alpha );
			
			var body0Point:Point = new Point( _bodies[ 0 ].x, _bodies[ 0 ].y );
			var body1Point:Point = new Point( _bodies[ 1 ].x, _bodies[ 1 ].y );
			var body2Point:Point = new Point( _bodies[ 2 ].x, _bodies[ 2 ].y );
			var body3Point:Point = new Point( _bodies[ 3 ].x, _bodies[ 3 ].y );
			
			
			var cpl:Point 	= new Point();
			var cp1:Point 	= new Point();
			cp1.x 			= (_bodies[ 0 ].x + _bodies[ 3 ].x) * .5;
			cp1.y 			= (_bodies[ 0 ].y + _bodies[ 3 ].y) * .5;
			
			graphics.moveTo( cp1.x, cp1.y );
				
			var i:int;
			for ( i = 0 ; i < 3 ; i++)
			{
				cpl.x = (_bodies[ i ].x + _bodies[ i+1 ].x) * .5;
				cpl.y = (_bodies[ i ].y + _bodies[ i+1 ].y) * .5;
				
				graphics.curveTo( _bodies[ i ].x, _bodies[ i ].y, cpl.x, cpl.y );
			}
			
			graphics.curveTo( _bodies[ i ].x, _bodies[ i ].y, cp1.x, cp1.y );
			graphics.endFill();
			
			
			// 
			var d1:Number = Point.distance( body0Point, body2Point ); 
			var d2:Number = Point.distance( body1Point, body3Point ); 
			
			if ( d1 > 200 && d2 > 200 )
			{
				if ( !_creationComplete )
				{
					_creationComplete = true;
					
					var j2:JointConnection;
					for each ( j2 in _bodiesConnections )
					{
						j2.destroy();
						j2 = null;
					}
					
					var center:Point 	= Point.interpolate( body0Point, body2Point, .5 );
					
					_bodies[4].destroy();
					_bodies[4]			= null;
					_bodies[4]			= new VertexBody( center, 2, 1, 1, 1, 1, 1 );
					
					_bodiesConnections	= PhysicHelper.ConnectBodies( _bodies, JointConnection.DISTANCE_JOINT );
				}
			}
				
		}
		
		public function expand():void
		{
			var vx:Number		= 0.05779610841224591; 
			var vy:Number 		= 0.08833225900307298;
			
			// var vx:Number 		= (_) / Config.WORLDSCALE;
			// var vy:Number 		= (__) / Config.WORLDSCALE;
		
			vx *= .25;
			vy *= .25;
			
			var b0:b2Body 		= _bodies[ 0 ].body;
			var f0:b2Vec2		= new b2Vec2( -vx, -vy );
			var fap0:b2Vec2		= b0.GetWorldCenter();
			b0.ApplyImpulse( f0, fap0 );
			
			var b1:b2Body 		= _bodies[ 1 ].body;
			var f1:b2Vec2		= new b2Vec2( vx, -vy );
			var fap1:b2Vec2		= b1.GetWorldCenter();
			b1.ApplyImpulse( f1, fap1 );
			
			
			var b2:b2Body 		= _bodies[ 2 ].body;
			var f2:b2Vec2		= new b2Vec2( vx, 0 );
			var fap2:b2Vec2		= b2.GetWorldCenter();
			b2.ApplyImpulse( f2, fap2 );
			
			var b3:b2Body 		= _bodies[ 3 ].body;
			var f3:b2Vec2		= new b2Vec2( -vx, vy );
			var fap3:b2Vec2		= b3.GetWorldCenter();
			b3.ApplyImpulse( f3, fap3 );
			
		}

		public function get bodies():Vector.<VertexBody>
		{
			return _bodies;
		}

		public function set bodies(value:Vector.<VertexBody>):void
		{
			_bodies = value;
		}

		public function get color():Number
		{
			return _color;
		}

		public function set color(value:Number):void
		{
			_color = value;
		}
		
		
	}
}