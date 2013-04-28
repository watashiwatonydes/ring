package
{
	import Box2D.Dynamics.b2Body;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.filters.BlurFilter;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	import physics.JointConnection;
	import physics.VertexBody;
	
	public class Chord extends Sprite
	{
		private var _vertices:Vector.<VertexBody>;
		private var _staticVerticesLeft:Vector.<VertexBody>;
		private var _staticVerticesRight:Vector.<VertexBody>;
		private var _connections:Vector.<JointConnection>;

		private var _offsetX:Number;
		private var _chordIndex:int;
		
		
		public function Chord( offsetX:Number, chordIndex:int )
		{
			super();
			
			_offsetX 	= offsetX;
			_chordIndex = chordIndex;
			
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		public function init( event:Event ):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			_vertices 				= new Vector.<VertexBody>();
			_staticVerticesLeft		= new Vector.<VertexBody>();
			_staticVerticesRight 	= new Vector.<VertexBody>();
			_connections 			= new Vector.<JointConnection>();
			
			var i:int;
			var n:int = 5;
			var incY:Number = stage.stageHeight / n;
			
			var v:VertexBody; // dynamic
			var w:VertexBody; // static attach on left
			var z:VertexBody; // static attach on right
			
			var p:Point 	= new Point();
			var q:Point 	= new Point();
			var r:Point 	= new Point();
			var posY:Number = incY / 2;
			
			
			p.x = _offsetX;
			q.x = p.x - 200;
			r.x = p.x + 200;
			q.y = r.y = p.y = 0;
			
			var topAttach:VertexBody = new VertexBody( p, 1 );
			var topLeftAttach:VertexBody = new VertexBody( p, 1 );
			var topRightAttach:VertexBody = new VertexBody( p, 1 );
			
			addChild( topAttach );
			addChild( topLeftAttach );
			addChild( topRightAttach );
			
			_vertices.push( topAttach );
			_staticVerticesLeft.push( topAttach );
			_staticVerticesRight.push( topAttach );
			
			for ( i = 0 ; i < n ; i++ )
			{
				p.y = posY;
				q.y = p.y;
				r.y = p.y;
				
				v = new VertexBody( p );
				_vertices.push( v );
				
				w = new VertexBody( q, 1 );
				_staticVerticesLeft.push( w );
				
				z = new VertexBody( r, 1 );
				_staticVerticesRight.push( z );
				
				addChild( v );
				addChild( w );
				addChild( z );
				
				posY += incY; 
			}
			
			p.y = q.y = r.y = stage.stageHeight;
			
			var bottomAttach:VertexBody = new VertexBody( p, 1 );
			var bottomLeftAttach:VertexBody = new VertexBody( q, 1 );
			var bottomRightAttach:VertexBody = new VertexBody( r, 1 );
			
			addChild( bottomAttach );
			addChild( bottomLeftAttach );
			addChild( bottomRightAttach );
			
			_vertices.push( bottomAttach );
			_staticVerticesLeft.push( bottomLeftAttach );
			_staticVerticesRight.push( bottomRightAttach );
			
			var ln:int = _vertices.length;
			var co:JointConnection;
			var co2:JointConnection;
			var co3:JointConnection;
			var a:VertexBody;
			var b:VertexBody;
			var l:VertexBody;
			var ri:VertexBody;
			
			for ( i = 0 ; i < ln - 1; i++ )
			{
				a 	= _vertices[i]
				b 	= _vertices[i+1]
				
				co 	= new JointConnection( JointConnection.DISTANCE_JOINT, a, b, 1, .01 );  // > 2 for consistency
				_connections.push( co );
				addChild( co );
			}
			
			for ( i = 0 ; i < ln - 1; i += 1 )
			{
				a 	= _vertices[i]
				b 	= _vertices[i+1]
				l 	= _staticVerticesLeft[i+1]
				ri 	= _staticVerticesRight[i+1]
				
				co2 	= new JointConnection( JointConnection.DISTANCE_JOINT, l, b, 2, .001 );
				_connections.push( co2 );
				addChild( co2 );
				// co2.draw();
				
				co3 	= new JointConnection( JointConnection.DISTANCE_JOINT, b, ri, 2, .001 );
				_connections.push( co3 );
				addChild( co3 );
				// co3.draw();
			}

		}		

		public function update( event:TimerEvent ):void
		{
			var ln:int = _vertices.length;
			var i:int;
			var v:VertexBody;
			var e:ChordEvent;
			
			for ( i = 0 ; i < ln ; i++ )
			{
				v = _vertices[ i ];
				v.update();
			
				if ( v.bodyType == b2Body.b2_dynamicBody )
				{
					if (Math.abs(v.pixelCoordinates.x - _offsetX) > 10)
					{
						e 					= new ChordEvent( ChordEvent.UPDATE );
						e.chordIndex	 	= _chordIndex;
						e.noteIndex 		= i - 1;
						e.pixelCoordinates 	= v.pixelCoordinates;
						dispatchEvent( e );
						
					}
				}
			}
			
			draw( event );
		}
		
		public function draw( event:TimerEvent ):void
		{
			
			if ((event.currentTarget as Timer).currentCount % 3 == 0)
				graphics.clear();
			
			graphics.lineStyle( 1, 0xffffff );
			
			var ln:int 		= _vertices.length;
			graphics.moveTo( _vertices[ 0 ].x, _vertices[ 0 ].y );
			
			var cpl:Point = new Point();
			var i:int;
			for ( i = 1 ; i < ln - 2 ; i++)
			{
				cpl.x = (_vertices[ i ].x + _vertices[ i+1 ].x) * .5;
				cpl.y = (_vertices[ i ].y + _vertices[ i+1 ].y) * .5;
				
				graphics.curveTo( _vertices[ i ].x, _vertices[ i ].y, cpl.x, cpl.y );
			}
			
			graphics.curveTo( _vertices[ i ].x, _vertices[ i ].y, _vertices[ i + 1 ].x, _vertices[ i + 1 ].y );
			graphics.endFill();
		}
		
		public function get vertices():Vector.<VertexBody>
		{
			return _vertices;
		}

		public function set vertices(value:Vector.<VertexBody>):void
		{
			_vertices = value;
		}
		
		
		
		
	}
}